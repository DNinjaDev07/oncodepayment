variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "app_namespace" {
  description = "Namespace for the CRUD application"
  type        = string
  default     = "oncodepayment"
}

variable "app_repo_url" {
  description = "Git repository URL for the application"
  type        = string
  default     = "https://github.com/DNinjaDev07/oncodepayment.git"
}

variable "app_target_revision" {
  description = "Git branch to track"
  type        = string
  default     = "master"
}
