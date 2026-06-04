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

variable "aws_region" {
  description = "AWS region for the EKS cluster"
  type        = string
  default     = "us-east-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "oncodepayment-dev"
}

variable "cluster_admin_principal_arns" {
  description = "IAM principal ARNs that get EKS cluster admin access"
  type        = list(string)
  default     = []
}

variable "cluster_viewer_principal_arns" {
  description = "IAM principal ARNs that get EKS cluster view access"
  type        = list(string)
  default     = []
}