
resource "aws_rds_global_cluster" "global_db" {
  for_each = {
    for cluster in var.rds_config : cluster.cluster_application => {
      "cluster_application" : cluster.cluster_application
      "engine" : cluster.engine
      "engine_version" : cluster.engine_version
      "database_name" : cluster.database_name
      "deletion_protection" : cluster.deletion_protection
    } if cluster.create_global_cluster
  }
  provider                  = aws.principal
  global_cluster_identifier = join("-", tolist([var.client, var.project,var.environment, each.key, "glb", var.service]))
  engine                    = each.value["engine"]
  engine_version            = each.value["engine_version"]
  database_name             = each.value["database_name"]
  deletion_protection       = each.value["deletion_protection"]
  storage_encrypted         = true

}

resource "aws_rds_cluster" "principal_cluster" {
  # checkov:skip=CKV_AWS_162: Currently, IAM authentication have limitations, for this reason is prefered to be skiped
  # checkov:skip=CKV2_AWS_8: Backup plan is not in the scope of this module
  # checkov:skip=CKV_AWS_324: Enabled logs are sent as variable
  # checkov:skip=CKV_AWS_133: Backup retention period is sent as variable
  # checkov:skip=CKV_AWS_96: Encryption validation is sent as variable
  # checkov:skip=CKV_AWS_139: Deletion Protection validation is sent as variable
  # checkov:skip=CKV_AWS_313: copy tags validation is sent as variable

  for_each = {
    for idx, item in flatten([for cluster in var.rds_config : [for rds in cluster.cluster_config : {
      "cluster_application" : cluster.cluster_application
      "create_global_cluster" : cluster.create_global_cluster
      "rds_index" : index(cluster.cluster_config, rds)
      "principal" : rds.principal
      "region" : rds.region
      "engine_mode" : rds.engine_mode
      "engine" : cluster.engine
      "engine_version" : cluster.engine_version
      "database_name" : cluster.database_name
      "manage_master_user_password" : rds.manage_master_user_password
      "master_password" : rds.master_password
      "master_username" : rds.master_username
      "vpc_security_group_ids" : rds.vpc_security_group_ids
      "subnet_ids" : rds.subnet_ids
      "backup_retention_period" : rds.backup_retention_period
      "skip_final_snapshot" : rds.skip_final_snapshot
      "preferred_backup_window" : rds.preferred_backup_window
      "storage_encrypted" : rds.storage_encrypted
      "kms_key_id" : rds.kms_key_id
      "deletion_protection" : cluster.deletion_protection
      "enabled_cloudwatch_logs_exports" : rds.enabled_cloudwatch_logs_exports
      "port" : rds.port
      "copy_tags_to_snapshot" : rds.copy_tags_to_snapshot
      "cluster_parameter" : rds.cluster_parameter
    }]]) : 
    "${item.cluster_application}-${item.region}-${idx}" => item if item.principal
  }

  provider                        = aws.principal
  global_cluster_identifier       = each.value["create_global_cluster"] ? aws_rds_global_cluster.global_db[each.value["cluster_application"]].id : null
  engine                          = each.value["engine"]
  engine_mode                     = each.value["engine_mode"]
  engine_version                  = each.value["engine_version"]
  cluster_identifier              = join("-", tolist([var.client, var.project, var.environment, "cluster", each.key, var.service]))
  database_name                   = each.value["database_name"]
  master_username                 = each.value["master_username"]
  port                            = each.value["port"]
  manage_master_user_password     = each.value["manage_master_user_password"] ? true : null
  master_password                 = !each.value["manage_master_user_password"] ? each.value["master_password"] : null
  vpc_security_group_ids          = each.value["vpc_security_group_ids"]
  db_subnet_group_name            = aws_db_subnet_group.principal_subnet_group["${each.key}"].name
  backup_retention_period         = each.value["backup_retention_period"]
  skip_final_snapshot             = each.value["skip_final_snapshot"]
  preferred_backup_window         = each.value["preferred_backup_window"]
  storage_encrypted               = each.value["storage_encrypted"]
  kms_key_id                      = each.value["kms_key_id"]
  db_cluster_parameter_group_name = try(aws_rds_cluster_parameter_group.principal_parameter["${each.value.cluster_application}-${each.value.region}-${each.value.rds_index}"].name, null)
  deletion_protection             = each.value["deletion_protection"]
  copy_tags_to_snapshot           = each.value["copy_tags_to_snapshot"]
  enabled_cloudwatch_logs_exports = each.value["enabled_cloudwatch_logs_exports"]
  tags                            = merge({ Name = "${join("-", tolist([var.client, var.project, var.environment, "cluster", each.key, var.service]))}" })
  depends_on = [ aws_rds_cluster_parameter_group.principal_parameter ]
}

resource "aws_rds_cluster" "secondary_cluster" {
  # checkov:skip=CKV_AWS_162: Currently, IAM authentication have limitations, for this reason is prefered to be skiped
  # checkov:skip=CKV2_AWS_8: Backup plan is not in the scope of this module
  # checkov:skip=CKV_AWS_324: Enabled logs are sent as variable
  # checkov:skip=CKV_AWS_133: Backup retention period is sent as variable
  # checkov:skip=CKV_AWS_96: Encryption validation is sent as variable
  # checkov:skip=CKV_AWS_139: Deletion Protection validation is sent as variable
  # checkov:skip=CKV_AWS_313: copy tags validation is sent as variable

  for_each = {
    for item in flatten([for cluster in var.rds_config : [for rds in cluster.cluster_config : {
      "cluster_application" : cluster.cluster_application
      "create_global_cluster" : cluster.create_global_cluster
      "rds_index" : index(cluster.cluster_config, rds)
      "principal" : rds.principal
      "region" : rds.region
      "engine_mode" : rds.engine_mode
      "engine" : cluster.engine
      "engine_version" : cluster.engine_version
      "database_name" : cluster.database_name
      "manage_master_user_password" : rds.manage_master_user_password
      "master_password" : rds.master_password
      "master_username" : rds.master_username
      "vpc_security_group_ids" : rds.vpc_security_group_ids
      "subnet_ids" : rds.subnet_ids
      "backup_retention_period" : rds.backup_retention_period
      "skip_final_snapshot" : rds.skip_final_snapshot
      "preferred_backup_window" : rds.preferred_backup_window
      "storage_encrypted" : rds.storage_encrypted
      "kms_key_id" : rds.kms_key_id
      "deletion_protection" : cluster.deletion_protection
      "enabled_cloudwatch_logs_exports" : rds.enabled_cloudwatch_logs_exports
      "port" : rds.port
      "copy_tags_to_snapshot" : rds.copy_tags_to_snapshot
      "cluster_parameter" : rds.cluster_parameter
      "service" : rds.service
    }]]) : "${item.service}-${item.region}-${item.rds_index}" => item if !item.principal
  }
  provider                        = aws.secondary
  global_cluster_identifier       = each.value["create_global_cluster"] ? aws_rds_global_cluster.global_db[each.value["cluster_application"]].id : null
  engine                          = each.value["engine"]
  engine_mode                     = each.value["engine_mode"]
  engine_version                  = each.value["engine_version"]
  cluster_identifier              = join("-", tolist([var.client, var.project, var.environment, "cluster", each.key, var.service]))
  port                            = each.value["port"]
  vpc_security_group_ids          = each.value["vpc_security_group_ids"]
  db_subnet_group_name            = aws_db_subnet_group.secondary_subnet_group[each.key].name
  backup_retention_period         = each.value["backup_retention_period"]
  skip_final_snapshot             = each.value["skip_final_snapshot"]
  preferred_backup_window         = each.value["preferred_backup_window"]
  storage_encrypted               = each.value["storage_encrypted"]
  kms_key_id                      = each.value["kms_key_id"]
  db_cluster_parameter_group_name = try(aws_rds_cluster_parameter_group.secondary_parameter["${each.value.service}-${each.value.region}-${each.value.rds_index}"].name, null)
  deletion_protection             = each.value["deletion_protection"]
  copy_tags_to_snapshot           = each.value["copy_tags_to_snapshot"]
  enabled_cloudwatch_logs_exports = each.value["enabled_cloudwatch_logs_exports"]
  tags                            = merge({ Name = "${join("-", tolist([var.client, var.project, var.environment, "cluster", each.key, var.service]))}" })
  depends_on = [ aws_rds_cluster_parameter_group.secondary_parameter ]
}

resource "aws_rds_cluster_instance" "principal_cluster_instances" {
  # checkov:skip=CKV_AWS_354: Kms performance insights validation is sent as variable
  # checkov:skip=CKV_AWS_353: Performance insights validation is sent as variable
  # checkov:skip=CKV_AWS_118: Enhanced monitoring validation is sent as variable
  # checkov:skip=CKV_AWS_226: auto minor update validation is sent as variable
  for_each = {
    for item in flatten([for cluster in var.rds_config : [for rds in cluster.cluster_config : [for instance in rds.cluster_instances : {
      "cluster_application" : cluster.cluster_application
      "rds_index" : index(cluster.cluster_config, rds)
      "instance_index" : index(rds.cluster_instances, instance)
      "region" : rds.region
      "principal" : rds.principal
      "instance_class" : instance.instance_class
      "publicly_accessible" : instance.publicly_accessible
      "kms_key_id" : rds.kms_key_id
      "auto_minor_version_upgrade" : instance.auto_minor_version_upgrade
      "performance_insights_enabled" : instance.performance_insights_enabled
      "performance_insights_retention_period" : instance.performance_insights_retention_period
      "monitoring_interval" : instance.monitoring_interval
    }]]]) : "${item.cluster_application}-instance-${item.instance_index}" => item if item.principal
  }
  provider                              = aws.principal
  identifier                            = join("-", tolist([var.client, var.project, var.environment, "rds-instance", each.value["cluster_application"] , var.service, each.value["instance_index"] + 1]))
  cluster_identifier                    = aws_rds_cluster.principal_cluster["${each.value.cluster_application}-${each.value.region}-${each.value.rds_index}"].id
  instance_class                        = each.value["instance_class"]
  engine                                = aws_rds_cluster.principal_cluster["${each.value.cluster_application}-${each.value.region}-${each.value.rds_index}"].engine
  engine_version                        = aws_rds_cluster.principal_cluster["${each.value.cluster_application}-${each.value.region}-${each.value.rds_index}"].engine_version
  publicly_accessible                   = each.value["publicly_accessible"]
  auto_minor_version_upgrade            = each.value["auto_minor_version_upgrade"]
  performance_insights_enabled          = each.value["performance_insights_enabled"]
  performance_insights_kms_key_id       = each.value["performance_insights_enabled"] ? each.value["kms_key_id"] : null
  performance_insights_retention_period = each.value["performance_insights_retention_period"]
  db_parameter_group_name               = try(aws_db_parameter_group.principal_parameter["${each.value.cluster_application}-${each.value.region}-${each.value.rds_index}"].name, null)
  monitoring_interval                   = each.value["monitoring_interval"]
  tags                                  = merge({ Name = "${join("-", tolist([var.client, var.project, var.environment, "rds-instance", each.value["cluster_application"] , var.service, each.value["instance_index"] + 1]))}" })

  depends_on = [ aws_db_parameter_group.principal_parameter ]
}

resource "aws_rds_cluster_instance" "secondary_cluster_instances" {
  # checkov:skip=CKV_AWS_354: Kms performance insights validation is sent as variable
  # checkov:skip=CKV_AWS_353: Performance insights validation is sent as variable
  # checkov:skip=CKV_AWS_118: Enhanced monitoring validation is sent as variable
  # checkov:skip=CKV_AWS_226: auto minor update validation is sent as variable
  for_each = {
    for item in flatten([for cluster in var.rds_config : [for rds in cluster.cluster_config : [for instance in rds.cluster_instances : {
      "cluster_application" : cluster.cluster_application
      "rds_index" : index(cluster.cluster_config, rds)
      "instance_index" : index(rds.cluster_instances, instance)
      "principal" : rds.principal
      "region" : rds.region
      "service" : rds.service
      "instance_class" : instance.instance_class
      "publicly_accessible" : instance.publicly_accessible
      "kms_key_id" : rds.kms_key_id
      "auto_minor_version_upgrade" : instance.auto_minor_version_upgrade
      "performance_insights_enabled" : instance.performance_insights_enabled
      "performance_insights_retention_period" : instance.performance_insights_retention_period
      "monitoring_interval" : instance.monitoring_interval
    }]]]) : "${item.service}-instance-${item.instance_index}" => item if !item.principal
  }
  provider                              = aws.secondary
  identifier                            = join("-", tolist([var.client, var.project, var.environment, "rds-instance", each.value["cluster_application"] , var.service, each.value["instance_index"] + 1]))
  cluster_identifier                    = aws_rds_cluster.secondary_cluster["${each.value.service}-${each.value.region}-${each.value.rds_index}"].id
  instance_class                        = each.value["instance_class"]
  engine                                = aws_rds_cluster.secondary_cluster["${each.value.service}-${each.value.region}-${each.value.rds_index}"].engine
  engine_version                        = aws_rds_cluster.secondary_cluster["${each.value.service}-${each.value.region}-${each.value.rds_index}"].engine_version
  publicly_accessible                   = each.value["publicly_accessible"]
  auto_minor_version_upgrade            = each.value["auto_minor_version_upgrade"]
  performance_insights_enabled          = each.value["performance_insights_enabled"]
  performance_insights_kms_key_id       = each.value["performance_insights_enabled"] ? each.value["kms_key_id"] : null
  performance_insights_retention_period = each.value["performance_insights_retention_period"]
  db_parameter_group_name               = try(aws_db_parameter_group.secondary_parameter["${each.value.service}-${each.value.region}-${each.value.rds_index}"].name, null)
  monitoring_interval                   = each.value["monitoring_interval"]
  tags                                  = merge({ Name = "${join("-", tolist([var.client, var.project, var.environment, "rds-instance", each.value["cluster_application"] , var.service, each.value["instance_index"] + 1]))}" })
}

resource "aws_db_subnet_group" "principal_subnet_group" {
  for_each = {
    for idx, item in flatten([for cluster in var.rds_config : [for rds in cluster.cluster_config : {
      "cluster_application" : cluster.cluster_application
      "rds_index" : index(cluster.cluster_config, rds)
      "principal" : rds.principal
      "region" : rds.region
      "subnet_ids" : rds.subnet_ids
    }]]) : 
    "${item.cluster_application}-${item.region}-${idx}" => item if item.principal
  }

  provider   = aws.principal
  name       = join("-", tolist([var.client, var.project, var.environment, "sn-grp", each.key, var.service]))
  subnet_ids = each.value["subnet_ids"]
  tags       = merge({
    Name = join("-", tolist([var.client, var.project, var.environment, "sn-grp", each.key, var.service]))
  })
}


resource "aws_db_subnet_group" "secondary_subnet_group" {
  for_each = {
    for item in flatten([for cluster in var.rds_config : [for rds in cluster.cluster_config : {
      "cluster_application" : cluster.cluster_application
      "rds_index" : index(cluster.cluster_config, rds)
      "principal" : rds.principal
      "region" : rds.region
      "subnet_ids" : rds.subnet_ids
      "service" : rds.service

    }]]) : "${item.service}-${item.region}-${item.rds_index}" => item if !item.principal
  }
  provider   = aws.secondary
  name       = join("-", tolist([var.client, var.project, var.environment, "sn-grp", each.key, var.service]))
  subnet_ids = each.value["subnet_ids"]
  tags       = merge({ Name = "${join("-", tolist([var.client, var.project, var.environment, "sn-grp", each.key, var.service]))}" })
}

resource "aws_db_parameter_group" "principal_parameter" {

  for_each = {
    for item in flatten([for cluster in var.rds_config : [for rds in cluster.cluster_config : {
      "cluster_application" : cluster.cluster_application
      "rds_index" : index(cluster.cluster_config, rds)
      "principal" : rds.principal
      "region" : rds.region
      "family" : rds.instance_parameter.family
      "parameters" : rds.instance_parameter.parameters

    } if length(rds.instance_parameter.parameters) > 0 && rds.principal]]) :
    "${item.cluster_application}-${item.region}-${item.rds_index}" => item
  }
  provider   = aws.principal
  name   = join("-", tolist([var.client, var.project, var.environment, "instance-parameter", each.key,  var.service]))
  family = each.value["family"]

  dynamic "parameter" {
    for_each = each.value["parameters"]
    content {
      name         = parameter.value["name"]
      value        = parameter.value["value"]
      apply_method = parameter.value["apply_method"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
resource "aws_db_parameter_group" "secondary_parameter" {

  for_each = {
    for item in flatten([for cluster in var.rds_config : [for rds in cluster.cluster_config : {
      "cluster_application" : cluster.cluster_application
      "rds_index" : index(cluster.cluster_config, rds)
      "principal" : rds.principal
      "region" : rds.region
      "family" : rds.instance_parameter.family
      "parameters" : rds.instance_parameter.parameters
      "service" : rds.service

   } if length(rds.instance_parameter.parameters) > 0 && !rds.principal]]) :
    "${item.service}-${item.region}-${item.rds_index}" => item
  }
  provider   = aws.secondary
  name   = join("-", tolist([var.client, var.project, var.environment, "instance-parameter", each.key,  var.service]))
  family = each.value["family"]

  dynamic "parameter" {
    for_each = each.value["parameters"]
    content {
      name         = parameter.value["name"]
      value        = parameter.value["value"]
      apply_method = parameter.value["apply_method"]
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_rds_cluster_parameter_group" "principal_parameter" {
  for_each = {
    for item in flatten([for cluster in var.rds_config : [for rds in cluster.cluster_config : {
      "cluster_application" : cluster.cluster_application
      "rds_index" : index(cluster.cluster_config, rds)
      "principal" : rds.principal
      "region" : rds.region
      "family" : rds.cluster_parameter.family
      "description" : rds.cluster_parameter.description
      "parameters" : rds.cluster_parameter.parameters

    }]]) :
    "${item.cluster_application}-${item.region}-${item.rds_index}" => item
    if length(item.parameters) > 0 && item.principal
  }
  provider   = aws.principal
  name        = join("-", tolist([var.client, var.project, var.environment, "cluster-parameter", each.key ,  var.service]))
  family      = each.value["family"]
  description = each.value["description"]

  dynamic "parameter" {
    for_each = each.value["parameters"]
    content {
      name         = parameter.value["name"]
      value        = parameter.value["value"]
      apply_method = parameter.value["apply_method"]
    }
  }

}
resource "aws_rds_cluster_parameter_group" "secondary_parameter" {
  for_each = {
    for item in flatten([for cluster in var.rds_config : [for rds in cluster.cluster_config : {
      "cluster_application" : cluster.cluster_application
      "rds_index" : index(cluster.cluster_config, rds)
      "principal" : rds.principal
      "region" : rds.region
      "family" : rds.cluster_parameter.family
      "description" : rds.cluster_parameter.description
      "parameters" : rds.cluster_parameter.parameters
      "service" : rds.service
    }]]) :
    "${item.service}-${item.region}-${item.rds_index}" => item
    if length(item.parameters) > 0 && !item.principal
  }
  provider   = aws.secondary
  name        = join("-", tolist([var.client, var.project, var.environment, "cluster-parameter", each.key ,  var.service]))
  family      = each.value["family"]
  description = each.value["description"]

  dynamic "parameter" {
    for_each = each.value["parameters"]
    content {
      name         = parameter.value["name"]
      value        = parameter.value["value"]
      apply_method = parameter.value["apply_method"]
    }
  }

}