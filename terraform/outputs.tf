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
