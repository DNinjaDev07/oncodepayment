#!/usr/bin/env bash
set -euo pipefail

PROFILE="${AWS_PROFILE:-default}"
REGION="${AWS_REGION:-us-east-2}"
CLUSTER_NAME="${CLUSTER_NAME:-oncodepayment-dev}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/terraform"

export AWS_PROFILE="${PROFILE}"
export AWS_REGION="${REGION}"
export AWS_DEFAULT_REGION="${REGION}"
export AWS_PAGER=""

confirm() {
  local prompt="$1"
  read -r -p "${prompt} Type yes to continue: " answer
  if [[ "${answer}" != "yes" ]]; then
    echo "[ABORT] Stopped before: ${prompt}"
    exit 1
  fi
}

run_tf_apply() {
  terraform -chdir="${TF_DIR}" apply "$@"
}

run_tf_plan() {
  terraform -chdir="${TF_DIR}" plan "$@"
}

echo "[INFO] OnCode Payment EKS apply flow"
echo "[INFO] AWS_PROFILE=${PROFILE}"
echo "[INFO] AWS_REGION=${REGION}"
echo "[INFO] CLUSTER_NAME=${CLUSTER_NAME}"
echo

confirm "Start Terraform init/validate and AWS infrastructure apply?"

terraform -chdir="${TF_DIR}" init
terraform -chdir="${TF_DIR}" validate

AWS_TARGETS=(
  -target=module.vpc
  -target=module.eks
  -target=aws_secretsmanager_secret.postgres_credentials
  -target=aws_iam_policy.external_secrets_read_postgres
  -target=aws_iam_role.external_secrets
  -target=aws_iam_role_policy_attachment.external_secrets_read_postgres
  -target=aws_iam_role.ebs_csi
  -target=aws_iam_role_policy_attachment.ebs_csi
  -target=aws_eks_addon.ebs_csi
)

echo "[INFO] Planning AWS substrate, EKS, Secrets Manager metadata, IRSA, and EBS CSI"
AWS_PROFILE="${PROFILE}" AWS_REGION="${REGION}" run_tf_plan "${AWS_TARGETS[@]}"
confirm "Apply AWS substrate, EKS, Secrets Manager metadata, IRSA, and EBS CSI?"
AWS_PROFILE="${PROFILE}" AWS_REGION="${REGION}" run_tf_apply "${AWS_TARGETS[@]}"

echo "[INFO] Refreshing kubeconfig for recreated EKS cluster"
AWS_PROFILE="${PROFILE}" aws eks update-kubeconfig \
  --region "${REGION}" \
  --name "${CLUSTER_NAME}" \
  --profile "${PROFILE}"

echo "[INFO] Current kube context"
kubectl config current-context

echo "[INFO] Waiting for nodes to become Ready"
kubectl wait --for=condition=Ready nodes --all --timeout=15m
kubectl get nodes -o wide
echo

confirm "Create the EBS gp3 StorageClass?"

STORAGE_TARGETS=(
  -target=kubernetes_storage_class_v1.ebs_gp3
)

echo "[INFO] Planning the EBS gp3 StorageClass"
AWS_PROFILE="${PROFILE}" AWS_REGION="${REGION}" run_tf_plan "${STORAGE_TARGETS[@]}"
confirm "Apply the EBS gp3 StorageClass?"
AWS_PROFILE="${PROFILE}" AWS_REGION="${REGION}" run_tf_apply "${STORAGE_TARGETS[@]}"

echo "[INFO] Verifying EBS CSI and StorageClass"
kubectl get csidriver ebs.csi.aws.com
kubectl get storageclass ebs-gp3
kubectl get pods -n kube-system -l app=ebs-csi-controller
echo

confirm "Install External Secrets Operator and ClusterSecretStore?"

ESO_TARGETS=(
  -target=kubernetes_namespace.external_secrets
  -target=helm_release.external_secrets
  -target=kubectl_manifest.cluster_secret_store
)

echo "[INFO] Planning ESO and ClusterSecretStore"
AWS_PROFILE="${PROFILE}" AWS_REGION="${REGION}" run_tf_plan "${ESO_TARGETS[@]}"
confirm "Apply ESO and ClusterSecretStore?"
AWS_PROFILE="${PROFILE}" AWS_REGION="${REGION}" run_tf_apply "${ESO_TARGETS[@]}"

echo "[INFO] Verifying External Secrets Operator"
kubectl get pods -n external-secrets
kubectl get clustersecretstore aws-secrets-manager
echo

confirm "Install ingress-nginx, ArgoCD, app namespace, and ArgoCD Application?"

GITOPS_TARGETS=(
  -target=kubernetes_namespace.app
  -target=kubernetes_namespace.argocd
  -target=kubernetes_namespace.ingress_nginx
  -target=helm_release.nginx_ingress
  -target=helm_release.argocd
  -target=kubectl_manifest.argocd_app
)

echo "[INFO] Planning ingress, ArgoCD, and ArgoCD Application"
AWS_PROFILE="${PROFILE}" AWS_REGION="${REGION}" run_tf_plan "${GITOPS_TARGETS[@]}"
confirm "Apply ingress, ArgoCD, and ArgoCD Application?"
AWS_PROFILE="${PROFILE}" AWS_REGION="${REGION}" run_tf_apply "${GITOPS_TARGETS[@]}"

echo "[INFO] Verifying ArgoCD and app resources"
kubectl get pods -n argocd
kubectl get applications -n argocd
kubectl get externalsecret -n oncodepayment || true
kubectl get secret oncodepayment-secret -n oncodepayment || true
kubectl get pods -n oncodepayment || true

cat <<EOF

[DONE] Apply flow completed.

Important:
- ArgoCD reads the app chart from the configured Git repo and branch.
- Commit and push local Helm changes before expecting ArgoCD to sync the ExternalSecret changes.
- EKS, NAT, EC2, EBS, and Secrets Manager resources are now billing.
- Destroy when finished:
  ${ROOT_DIR}/scripts/destroy-eks-flow.sh
EOF
