locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    Project     = "oncodepayment"
    Environment = "dev"
    ManagedBy   = "terraform"
  }

  admin_access_entries = {
    for idx, arn in var.cluster_admin_principal_arns : "admin_${idx}" => {
      principal_arn = arn

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  viewer_access_entries = {
    for idx, arn in var.cluster_viewer_principal_arns : "viewer_${idx}" => {
      principal_arn = arn

      policy_associations = {
        view = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  access_entries = merge(
    local.admin_access_entries,
    local.viewer_access_entries
  )

  external_secrets_namespace       = "external-secrets"
  external_secrets_service_account = "external-secrets"
  postgres_secret_name             = "${var.cluster_name}/postgres"

  eks_oidc_provider_url = module.eks.oidc_provider
}
