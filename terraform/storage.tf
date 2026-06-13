resource "kubernetes_storage_class_v1" "ebs_gp3" {
  metadata {
    name = "ebs-gp3"

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true

  parameters = {
    type                 = "gp3"
    encrypted            = "true"
    fsType               = "ext4"
    "tagSpecification_1" = "Project=${local.tags.Project}"
    "tagSpecification_2" = "Environment=${local.tags.Environment}"
    "tagSpecification_3" = "ManagedBy=eks-ebs-csi"
  }

  depends_on = [aws_eks_addon.ebs_csi]
}
