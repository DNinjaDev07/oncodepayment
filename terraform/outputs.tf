output "argocd_initial_password" {
  description = "To retrieve the ArgoCD initial admin password"
  value       = "Run: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_oidc_provider_arn" {
  description = "IAM OIDC provider ARN for IRSA"
  value       = module.eks.oidc_provider_arn
}

output "cluster_oidc_provider_url" {
  description = "EKS OIDC provider URL used in IAM trust policy condition keys"
  value       = module.eks.oidc_provider
}

output "external_secrets_role_arn" {
  description = "IAM role ARN used by External Secrets Operator via IRSA"
  value       = aws_iam_role.external_secrets.arn
}

output "ebs_csi_role_arn" {
  description = "IAM role ARN used by the Amazon EBS CSI driver via IRSA"
  value       = aws_iam_role.ebs_csi.arn
}
