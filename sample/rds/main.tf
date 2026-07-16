# PC-IAC-026: main.tf SOLO invoca el módulo — NUNCA contiene bloques locals {}
# PC-IAC-009: Consume local.rds_config_transformed (no var.rds_config directamente)
# PC-IAC-005: providers inyectados con alias aws.principal y aws.secondary

module "rds" {
  source = "../../"

  providers = {
    aws.principal = aws.principal
    aws.secondary = aws.secondary
  }

  # Gobernanza
  client      = var.client
  project     = var.project
  environment = var.environment
  service     = var.service

  # Contraseña maestra — usar Secrets Manager (manage_master_user_password=true) siempre que sea posible
  # Si manage_master_user_password=false, inyectar aquí desde un data source de SM:
  # master_password = jsondecode(data.aws_secretsmanager_secret_version.rds_password.secret_string)["password"]
  master_password = ""

  # PC-IAC-026: Consumir el local transformado — NO var.rds_config directamente
  rds_config = local.rds_config_transformed
}
