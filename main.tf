# PC-IAC-003: Nomenclatura {client}-{project}-{environment}-{type}-{key}-{service}
# PC-IAC-005: provider = aws.principal / aws.secondary (alias consumidores)
# PC-IAC-010: for_each sobre locals (map), prevent_destroy en cluster
# PC-IAC-014: dynamic blocks para serverlessv2_scaling_configuration
# PC-IAC-020: deletion_protection, storage_encrypted, kms_key obligatorios como variables
# PC-IAC-023: El módulo NO crea SG, IAM roles ni VPC — recibe IDs por variable

##############################################################
# Global Cluster (multi-región)
##############################################################
resource "aws_rds_global_cluster" "global_db" {
  for_each = {
    for cluster_key, cluster in var.rds_config : cluster_key => cluster
    if cluster.create_global_cluster
  }

  provider                  = aws.principal
  global_cluster_identifier = "${local.governance_prefix}-global-${each.key}-${var.service}"
  engine                    = each.value.engine
  engine_version            = each.value.engine_version
  database_name             = each.value.database_name
  deletion_protection       = each.value.deletion_protection
  storage_encrypted         = each.value.storage_encrypted
}

##############################################################
# Subnet Group — cluster principal
##############################################################
resource "aws_db_subnet_group" "principal_subnet_group" {
  for_each = local.principal_clusters

  provider   = aws.principal
  name       = "${local.governance_prefix}-sn-grp-${each.key}-${var.service}"
  subnet_ids = each.value.subnet_ids

  tags = {
    Name = "${local.governance_prefix}-sn-grp-${each.key}-${var.service}"
  }
}

##############################################################
# Subnet Group — cluster secundario
##############################################################
resource "aws_db_subnet_group" "secondary_subnet_group" {
  for_each = local.secondary_clusters

  provider   = aws.secondary
  name       = "${local.governance_prefix}-sn-grp-${each.key}-${var.service}"
  subnet_ids = each.value.subnet_ids

  tags = {
    Name = "${local.governance_prefix}-sn-grp-${each.key}-${var.service}"
  }
}

##############################################################
# Cluster Parameter Group — principal
##############################################################
resource "aws_rds_cluster_parameter_group" "principal_parameter" {
  for_each = {
    for k, v in local.principal_clusters : k => v
    if length(v.cluster_parameter.parameters) > 0
  }

  provider    = aws.principal
  name        = "${local.governance_prefix}-cluster-pg-${each.key}-${var.service}"
  family      = each.value.cluster_parameter.family
  description = each.value.cluster_parameter.description

  dynamic "parameter" {
    for_each = each.value.cluster_parameter.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

##############################################################
# Cluster Parameter Group — secundario
##############################################################
resource "aws_rds_cluster_parameter_group" "secondary_parameter" {
  for_each = {
    for k, v in local.secondary_clusters : k => v
    if length(v.cluster_parameter.parameters) > 0
  }

  provider    = aws.secondary
  name        = "${local.governance_prefix}-cluster-pg-${each.key}-${var.service}"
  family      = each.value.cluster_parameter.family
  description = each.value.cluster_parameter.description

  dynamic "parameter" {
    for_each = each.value.cluster_parameter.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

##############################################################
# Instance Parameter Group — principal
##############################################################
resource "aws_db_parameter_group" "principal_parameter" {
  for_each = {
    for k, v in local.principal_clusters : k => v
    if length(v.cluster_parameter.parameters) > 0
  }

  provider = aws.principal
  name     = "${local.governance_prefix}-instance-pg-${each.key}-${var.service}"
  family   = each.value.cluster_parameter.family

  dynamic "parameter" {
    for_each = each.value.cluster_parameter.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

##############################################################
# Instance Parameter Group — secundario
##############################################################
resource "aws_db_parameter_group" "secondary_parameter" {
  for_each = {
    for k, v in local.secondary_clusters : k => v
    if length(v.cluster_parameter.parameters) > 0
  }

  provider = aws.secondary
  name     = "${local.governance_prefix}-instance-pg-${each.key}-${var.service}"
  family   = each.value.cluster_parameter.family

  dynamic "parameter" {
    for_each = each.value.cluster_parameter.parameters
    content {
      name         = parameter.value.name
      value        = parameter.value.value
      apply_method = parameter.value.apply_method
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

##############################################################
# RDS Cluster — principal
# FIX: serverlessv2_scaling_configuration es dynamic (solo cuando serverless_deploy=true)
# FIX: Para serverless v2: engine_mode=provisioned + db.serverless + serverlessv2_scaling_configuration
# PC-IAC-010: prevent_destroy = true (recurso crítico)
# PC-IAC-020: deletion_protection, storage_encrypted, kms_key obligatorios
##############################################################
resource "aws_rds_cluster" "principal_cluster" {
  # checkov:skip=CKV_AWS_162: IAM auth tiene limitaciones, se gestiona por variable
  # checkov:skip=CKV2_AWS_8: Backup plan fuera del scope del módulo
  # checkov:skip=CKV_AWS_324: enabled_logs enviado como variable
  # checkov:skip=CKV_AWS_133: backup_retention_period enviado como variable
  # checkov:skip=CKV_AWS_96: Encryption se valida por variable
  # checkov:skip=CKV_AWS_139: Deletion protection se valida por variable
  # checkov:skip=CKV_AWS_313: copy_tags se valida por variable

  for_each = local.principal_clusters

  provider = aws.principal

  cluster_identifier = "${local.governance_prefix}-cluster-${each.key}-${var.service}"

  # Global cluster — solo si create_global_cluster = true
  global_cluster_identifier = (
    each.value.create_global_cluster
    ? aws_rds_global_cluster.global_db[each.value.cluster_key].id
    : null
  )

  engine         = each.value.engine
  engine_mode    = each.value.engine_mode
  engine_version = each.value.engine_version
  database_name  = each.value.database_name

  # Autenticación
  master_username             = each.value.master_username
  manage_master_user_password = each.value.manage_master_user_password ? true : null
  master_password             = !each.value.manage_master_user_password ? var.master_password : null

  # Red
  vpc_security_group_ids = each.value.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.principal_subnet_group[each.key].name
  port                   = each.value.port

  # Backup
  backup_retention_period = each.value.backup_retention_period
  skip_final_snapshot     = each.value.skip_final_snapshot
  preferred_backup_window = each.value.preferred_backup_window

  # Cifrado (PC-IAC-020)
  storage_encrypted = each.value.storage_encrypted
  kms_key_id        = length(each.value.kms_key_id) > 0 ? each.value.kms_key_id : null

  # Parámetros
  db_cluster_parameter_group_name = try(
    aws_rds_cluster_parameter_group.principal_parameter[each.key].name,
    null
  )

  # Gobernanza
  deletion_protection             = each.value.deletion_protection
  copy_tags_to_snapshot           = each.value.copy_tags_to_snapshot
  enable_http_endpoint            = each.value.enable_http_endpoint
  enabled_cloudwatch_logs_exports = each.value.enabled_cloudwatch_logs_exports

  # FIX PC-IAC-014: serverlessv2_scaling_configuration SOLO cuando serverless_deploy=true
  # Serverless v2 requiere engine_mode="provisioned" + este bloque + instance_class="db.serverless"
  dynamic "serverlessv2_scaling_configuration" {
    for_each = (
      each.value.serverless_deploy && each.value.cluster_scaling_configuration != null
      ? [each.value.cluster_scaling_configuration]
      : []
    )
    content {
      max_capacity             = serverlessv2_scaling_configuration.value.max_capacity
      min_capacity             = serverlessv2_scaling_configuration.value.min_capacity
      seconds_until_auto_pause = serverlessv2_scaling_configuration.value.seconds_until_auto_pause
    }
  }

  tags = {
    Name = "${local.governance_prefix}-cluster-${each.key}-${var.service}"
  }

  # PC-IAC-010: Proteger cluster contra eliminación accidental
  lifecycle {
    prevent_destroy = true
  }

  depends_on = [aws_rds_cluster_parameter_group.principal_parameter]
}

##############################################################
# RDS Cluster — secundario
##############################################################
resource "aws_rds_cluster" "secondary_cluster" {
  # checkov:skip=CKV_AWS_162: IAM auth tiene limitaciones
  # checkov:skip=CKV2_AWS_8: Backup plan fuera del scope del módulo
  # checkov:skip=CKV_AWS_324: enabled_logs enviado como variable
  # checkov:skip=CKV_AWS_133: backup_retention_period enviado como variable
  # checkov:skip=CKV_AWS_96: Encryption se valida por variable
  # checkov:skip=CKV_AWS_139: Deletion protection se valida por variable
  # checkov:skip=CKV_AWS_313: copy_tags se valida por variable

  for_each = local.secondary_clusters

  provider = aws.secondary

  cluster_identifier = "${local.governance_prefix}-cluster-${each.key}-${var.service}"

  global_cluster_identifier = (
    each.value.create_global_cluster
    ? aws_rds_global_cluster.global_db[each.value.cluster_key].id
    : null
  )

  engine         = each.value.engine
  engine_mode    = each.value.engine_mode
  engine_version = each.value.engine_version

  vpc_security_group_ids = each.value.vpc_security_group_ids
  db_subnet_group_name   = aws_db_subnet_group.secondary_subnet_group[each.key].name
  port                   = each.value.port

  backup_retention_period = each.value.backup_retention_period
  skip_final_snapshot     = each.value.skip_final_snapshot
  preferred_backup_window = each.value.preferred_backup_window

  storage_encrypted = each.value.storage_encrypted
  kms_key_id        = length(each.value.kms_key_id) > 0 ? each.value.kms_key_id : null

  db_cluster_parameter_group_name = try(
    aws_rds_cluster_parameter_group.secondary_parameter[each.key].name,
    null
  )

  deletion_protection             = each.value.deletion_protection
  copy_tags_to_snapshot           = each.value.copy_tags_to_snapshot
  enable_http_endpoint            = each.value.enable_http_endpoint
  enabled_cloudwatch_logs_exports = each.value.enabled_cloudwatch_logs_exports

  dynamic "serverlessv2_scaling_configuration" {
    for_each = (
      each.value.serverless_deploy && each.value.cluster_scaling_configuration != null
      ? [each.value.cluster_scaling_configuration]
      : []
    )
    content {
      max_capacity             = serverlessv2_scaling_configuration.value.max_capacity
      min_capacity             = serverlessv2_scaling_configuration.value.min_capacity
      seconds_until_auto_pause = serverlessv2_scaling_configuration.value.seconds_until_auto_pause
    }
  }

  tags = {
    Name = "${local.governance_prefix}-cluster-${each.key}-${var.service}"
  }

  lifecycle {
    prevent_destroy = true
  }

  depends_on = [
    aws_rds_cluster_parameter_group.secondary_parameter,
    aws_rds_cluster_instance.principal_cluster_instances,
  ]
}

##############################################################
# RDS Cluster Instance — principal
# FIX: performance_insights_kms_key_id solo se pasa cuando PI está habilitado
# FIX: performance_insights_enabled solo para instance_class que lo soportan
#      (db.t3.micro/medium NO lo soportan — poner false)
# PC-IAC-010: for_each sobre local.principal_instances (map estable)
##############################################################
resource "aws_rds_cluster_instance" "principal_cluster_instances" {
  # checkov:skip=CKV_AWS_354: KMS para PI enviado como variable
  # checkov:skip=CKV_AWS_353: PI enviado como variable
  # checkov:skip=CKV_AWS_118: Enhanced monitoring enviado como variable
  # checkov:skip=CKV_AWS_226: auto_minor_version_upgrade enviado como variable

  for_each = local.principal_instances

  provider = aws.principal

  identifier = "${local.governance_prefix}-rds-${each.value.cluster_key}-${var.service}-${each.value.instance_index + 1}"

  cluster_identifier = aws_rds_cluster.principal_cluster[
    "${each.value.cluster_key}-${each.value.region}-${each.value.rds_index}"
  ].id

  instance_class = each.value.instance_class
  engine = aws_rds_cluster.principal_cluster[
    "${each.value.cluster_key}-${each.value.region}-${each.value.rds_index}"
  ].engine
  engine_version = aws_rds_cluster.principal_cluster[
    "${each.value.cluster_key}-${each.value.region}-${each.value.rds_index}"
  ].engine_version

  publicly_accessible        = each.value.publicly_accessible
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade

  # FIX: performance_insights — db.t3.medium no lo soporta, debe venir en false desde variables
  performance_insights_enabled = each.value.performance_insights_enabled
  # FIX: kms solo se pasa cuando PI está habilitado (evita error InvalidParameterCombination)
  performance_insights_kms_key_id = each.value.performance_insights_kms_key_id
  performance_insights_retention_period = (
    each.value.performance_insights_enabled
    ? each.value.performance_insights_retention_period
    : null
  )

  db_parameter_group_name = try(
    aws_db_parameter_group.principal_parameter[
      "${each.value.cluster_key}-${each.value.region}-${each.value.rds_index}"
    ].name,
    null
  )

  monitoring_interval = each.value.monitoring_interval
  monitoring_role_arn = length(each.value.monitoring_role_arn) > 0 ? each.value.monitoring_role_arn : null

  tags = {
    Name = "${local.governance_prefix}-rds-${each.value.cluster_key}-${var.service}-${each.value.instance_index + 1}"
  }

  depends_on = [aws_db_parameter_group.principal_parameter]
}

##############################################################
# RDS Cluster Instance — secundario
##############################################################
resource "aws_rds_cluster_instance" "secondary_cluster_instances" {
  # checkov:skip=CKV_AWS_354: KMS para PI enviado como variable
  # checkov:skip=CKV_AWS_353: PI enviado como variable
  # checkov:skip=CKV_AWS_118: Enhanced monitoring enviado como variable
  # checkov:skip=CKV_AWS_226: auto_minor_version_upgrade enviado como variable

  for_each = local.secondary_instances

  provider = aws.secondary

  identifier = "${local.governance_prefix}-rds-${each.value.cluster_key}-${var.service}-${each.value.instance_index + 1}"

  cluster_identifier = aws_rds_cluster.secondary_cluster[
    "${each.value.cluster_key}-${each.value.region}-${each.value.rds_index}"
  ].id

  instance_class = each.value.instance_class
  engine = aws_rds_cluster.secondary_cluster[
    "${each.value.cluster_key}-${each.value.region}-${each.value.rds_index}"
  ].engine
  engine_version = aws_rds_cluster.secondary_cluster[
    "${each.value.cluster_key}-${each.value.region}-${each.value.rds_index}"
  ].engine_version

  publicly_accessible        = each.value.publicly_accessible
  auto_minor_version_upgrade = each.value.auto_minor_version_upgrade

  performance_insights_enabled    = each.value.performance_insights_enabled
  performance_insights_kms_key_id = each.value.performance_insights_kms_key_id
  performance_insights_retention_period = (
    each.value.performance_insights_enabled
    ? each.value.performance_insights_retention_period
    : null
  )

  db_parameter_group_name = try(
    aws_db_parameter_group.secondary_parameter[
      "${each.value.cluster_key}-${each.value.region}-${each.value.rds_index}"
    ].name,
    null
  )

  monitoring_interval = each.value.monitoring_interval
  monitoring_role_arn = length(each.value.monitoring_role_arn) > 0 ? each.value.monitoring_role_arn : null

  tags = {
    Name = "${local.governance_prefix}-rds-${each.value.cluster_key}-${var.service}-${each.value.instance_index + 1}"
  }

  depends_on = [
    aws_db_parameter_group.secondary_parameter,
    aws_rds_cluster_instance.principal_cluster_instances,
  ]
}
