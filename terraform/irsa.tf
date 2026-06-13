data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "external_secrets_read_postgres_document" {
  statement {
    sid = "ReadPostgresSecret"

    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]

    resources = [
      aws_secretsmanager_secret.postgres_credentials.arn,
    ]
  }
}

resource "aws_iam_policy" "external_secrets_read_postgres" {
  name        = "${var.cluster_name}-external-secrets-read-postgres"
  description = "Allow External Secrets Operator to read the OnCode Payment PostgreSQL secret"
  policy      = data.aws_iam_policy_document.external_secrets_read_postgres_document.json
  tags        = local.tags
}

data "aws_iam_policy_document" "external_secrets_assume_role" {
  statement {
    sid     = "AllowExternalSecretsServiceAccount"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_provider_url}:sub"
      values = [
        "system:serviceaccount:${local.external_secrets_namespace}:${local.external_secrets_service_account}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "external_secrets" {
  name               = "${var.cluster_name}-external-secrets"
  assume_role_policy = data.aws_iam_policy_document.external_secrets_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "external_secrets_read_postgres" {
  role       = aws_iam_role.external_secrets.name
  policy_arn = aws_iam_policy.external_secrets_read_postgres.arn
}

data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    sid     = "AllowEbsCsiControllerServiceAccount"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.eks_oidc_provider_url}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ebs_csi" {
  name               = "${var.cluster_name}-ebs-csi"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  role       = aws_iam_role.ebs_csi.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicyV2"
}
