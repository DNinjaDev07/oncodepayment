resource "aws_secretsmanager_secret" "postgres_credentials" {
  name                    = "${var.cluster_name}/postgres"
  description             = "PostgreSQL credentials for OnCode Payment"
  recovery_window_in_days = 0

  tags = local.tags
}
