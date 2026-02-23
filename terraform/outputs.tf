output "argocd_initial_password" {
  description = "To retrieve the ArgoCD initial admin password"
  value       = "Run: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"
}
