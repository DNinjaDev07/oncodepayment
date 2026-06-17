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

destroy_targets() {
  terraform -chdir="${TF_DIR}" destroy "$@"
}

echo "[INFO] OnCode Payment EKS destroy flow"
echo "[INFO] AWS_PROFILE=${PROFILE}"
echo "[INFO] AWS_REGION=${REGION}"
echo "[INFO] CLUSTER_NAME=${CLUSTER_NAME}"
echo
echo "[WARN] This removes the application, platform components, EKS cluster, NAT gateway, and VPC."
echo

confirm "Start phased destruction?"

terraform -chdir="${TF_DIR}" init
terraform -chdir="${TF_DIR}" validate

echo "[INFO] Refreshing kubeconfig while EKS and admin access still exist"
aws eks update-kubeconfig \
  --region "${REGION}" \
  --name "${CLUSTER_NAME}" \
  --profile "${PROFILE}"

echo "[INFO] Current kube context"
kubectl config current-context

APP_TARGETS=(
  -target=kubectl_manifest.argocd_app
)

echo "[INFO] Phase 1: destroy the ArgoCD Application"
confirm "Destroy the ArgoCD Application?"
destroy_targets "${APP_TARGETS[@]}"

PLATFORM_TARGETS=(
  -target=kubectl_manifest.cluster_secret_store
  -target=helm_release.argocd
  -target=helm_release.nginx_ingress
  -target=helm_release.external_secrets
  -target=kubernetes_namespace.app
  -target=kubernetes_namespace.argocd
  -target=kubernetes_namespace.ingress_nginx
  -target=kubernetes_namespace.external_secrets
)

echo "[INFO] Phase 2: destroy platform Helm releases and namespaces"
confirm "Destroy ESO, ingress-nginx, ArgoCD, and their namespaces?"
destroy_targets "${PLATFORM_TARGETS[@]}"

echo "[INFO] Checking for EBS volumes created for OnCode Payment"
for attempt in {1..30}; do
  remaining_volumes="$(
    aws ec2 describe-volumes \
      --region "${REGION}" \
      --filters \
        "Name=tag:Project,Values=oncodepayment" \
        "Name=tag:ManagedBy,Values=eks-ebs-csi" \
        "Name=status,Values=creating,available,in-use,deleting" \
      --query 'length(Volumes)' \
      --output text \
      --no-cli-pager
  )"

  if [[ "${remaining_volumes}" == "0" ]]; then
    echo "[OK] No tagged OnCode Payment EBS volumes remain."
    break
  fi

  if [[ "${attempt}" == "30" ]]; then
    echo "[WARN] ${remaining_volumes} tagged EBS volume(s) still exist."
    echo "[WARN] Inspect them before leaving the AWS environment running."
    aws ec2 describe-volumes \
      --region "${REGION}" \
      --filters \
        "Name=tag:Project,Values=oncodepayment" \
        "Name=tag:ManagedBy,Values=eks-ebs-csi" \
      --query 'Volumes[*].{id:VolumeId,state:State,az:AvailabilityZone}' \
      --no-cli-pager
    exit 1
  fi

  echo "[INFO] Waiting for ${remaining_volumes} EBS volume(s) to be deleted..."
  sleep 10
done

echo "[INFO] Phase 3: destroy remaining AWS infrastructure"
echo "[INFO] This includes the StorageClass, EBS CSI add-on and IRSA, EKS access entries, node groups, EKS, NAT gateway, VPC, and Secrets Manager secret."
confirm "Run the final full Terraform destroy?"
terraform -chdir="${TF_DIR}" destroy

echo "[INFO] Verifying that the EKS cluster no longer exists"
if aws eks describe-cluster \
  --region "${REGION}" \
  --name "${CLUSTER_NAME}" \
  --no-cli-pager >/dev/null 2>&1; then
  echo "[WARN] EKS cluster still exists: ${CLUSTER_NAME}"
  exit 1
else
  echo "[OK] EKS cluster is absent."
fi

echo "[INFO] NAT gateway states for Project=oncodepayment"
aws ec2 describe-nat-gateways \
  --region "${REGION}" \
  --filter "Name=tag:Project,Values=oncodepayment" \
  --query 'NatGateways[*].{id:NatGatewayId,state:State,vpc:VpcId}' \
  --no-cli-pager

echo "[DONE] Phased destroy completed."
