# PC-IAC-003: Nomenclatura centralizada — {client}-{project}-{environment}-{type}-{key}-{service}
# PC-IAC-009: Lógica de inyección y transformación exclusiva en locals.tf
# PC-IAC-012: Estructuras de datos reutilizables

locals {
  # Prefijo base de gobernanza (PC-IAC-003)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # ----------------------------------------------------------------
  # Aplanar rds_config (map → lista de clusters principal)
  # Genera clave única: "{cluster_key}-{region}-{idx}"
  # ----------------------------------------------------------------
  principal_clusters = {
    for item in flatten([
      for cluster_key, cluster in var.rds_config : [
        for idx, rds in cluster.cluster_config : {
          cluster_key               = cluster_key
          rds_index                 = idx
          principal                 = rds.principal
          region                    = rds.region
          engine_mode               = rds.engine_mode
          engine                    = cluster.engine
          engine_version            = cluster.engine_version
          database_name             = cluster.database_name
          manage_master_user_password = rds.manage_master_user_password
          master_username           = rds.master_username
          vpc_security_group_ids    = rds.vpc_security_group_ids
          subnet_ids                = rds.subnet_ids
          backup_retention_period   = rds.backup_retention_period
          skip_final_snapshot       = rds.skip_final_snapshot
          preferred_backup_window   = rds.preferred_backup_window
          storage_encrypted         = cluster.storage_encrypted
          kms_key_id                = rds.kms_key_id
          deletion_protection       = cluster.deletion_protection
          enabled_cloudwatch_logs_exports = rds.enabled_cloudwatch_logs_exports
          port                      = rds.port
          copy_tags_to_snapshot     = rds.copy_tags_to_snapshot
          enable_http_endpoint      = rds.enable_http_endpoint
          cluster_parameter         = rds.cluster_parameter
          create_global_cluster     = cluster.create_global_cluster
          serverless_deploy         = cluster.serverless_deploy
          # cluster_scaling_configuration solo existe cuando serverless_deploy=true
          cluster_scaling_configuration = rds.cluster_scaling_configuration
        } if rds.principal
      ]
    ]) : "${item.cluster_key}-${item.region}-${item.rds_index}" => item
  }

  secondary_clusters = {
    for item in flatten([
      for cluster_key, cluster in var.rds_config : [
        for idx, rds in cluster.cluster_config : {
          cluster_key               = cluster_key
          rds_index                 = idx
          principal                 = rds.principal
          region                    = rds.region
          engine_mode               = rds.engine_mode
          engine                    = cluster.engine
          engine_version            = cluster.engine_version
          database_name             = cluster.database_name
          manage_master_user_password = rds.manage_master_user_password
          master_username           = rds.master_username
          vpc_security_group_ids    = rds.vpc_security_group_ids
          subnet_ids                = rds.subnet_ids
          backup_retention_period   = rds.backup_retention_period
          skip_final_snapshot       = rds.skip_final_snapshot
          preferred_backup_window   = rds.preferred_backup_window
          storage_encrypted         = cluster.storage_encrypted
          kms_key_id                = rds.kms_key_id
          deletion_protection       = cluster.deletion_protection
          enabled_cloudwatch_logs_exports = rds.enabled_cloudwatch_logs_exports
          port                      = rds.port
          copy_tags_to_snapshot     = rds.copy_tags_to_snapshot
          enable_http_endpoint      = rds.enable_http_endpoint
          cluster_parameter         = rds.cluster_parameter
          create_global_cluster     = cluster.create_global_cluster
          serverless_deploy         = cluster.serverless_deploy
          cluster_scaling_configuration = rds.cluster_scaling_configuration
          service                   = rds.service
        } if !rds.principal
      ]
    ]) : "${item.cluster_key}-${item.region}-${item.rds_index}" => item
  }

  # ----------------------------------------------------------------
  # Instancias del cluster principal
  # Clave única: "{cluster_key}-instance-{instance_idx}"
  # ----------------------------------------------------------------
  principal_instances = {
    for item in flatten([
      for cluster_key, cluster in var.rds_config : [
        for rds_idx, rds in cluster.cluster_config : [
          for inst_idx, instance in rds.cluster_instances : {
            cluster_key                           = cluster_key
            rds_index                             = rds_idx
            instance_index                        = inst_idx
            region                                = rds.region
            principal                             = rds.principal
            instance_class                        = instance.instance_class
            publicly_accessible                   = instance.publicly_accessible
            auto_minor_version_upgrade            = instance.auto_minor_version_upgrade
            performance_insights_enabled          = instance.performance_insights_enabled
            performance_insights_retention_period = instance.performance_insights_retention_period
            # CORRECCIÓN: solo pasar kms cuando PI está habilitado (PC-IAC-020)
            performance_insights_kms_key_id = (
              instance.performance_insights_enabled && length(instance.performance_insights_kms_key_id) > 0
              ? instance.performance_insights_kms_key_id
              : null
            )
            monitoring_interval = instance.monitoring_interval
            monitoring_role_arn = instance.monitoring_role_arn
          } if rds.principal
        ]
      ]
    ]) : "${item.cluster_key}-instance-${item.instance_index}" => item
  }

  secondary_instances = {
    for item in flatten([
      for cluster_key, cluster in var.rds_config : [
        for rds_idx, rds in cluster.cluster_config : [
          for inst_idx, instance in rds.cluster_instances : {
            cluster_key                           = cluster_key
            rds_index                             = rds_idx
            instance_index                        = inst_idx
            region                                = rds.region
            principal                             = rds.principal
            service                               = rds.service
            instance_class                        = instance.instance_class
            publicly_accessible                   = instance.publicly_accessible
            auto_minor_version_upgrade            = instance.auto_minor_version_upgrade
            performance_insights_enabled          = instance.performance_insights_enabled
            performance_insights_retention_period = instance.performance_insights_retention_period
            performance_insights_kms_key_id = (
              instance.performance_insights_enabled && length(instance.performance_insights_kms_key_id) > 0
              ? instance.performance_insights_kms_key_id
              : null
            )
            monitoring_interval = instance.monitoring_interval
            monitoring_role_arn = instance.monitoring_role_arn
          } if !rds.principal
        ]
      ]
    ]) : "${item.cluster_key}-instance-${item.instance_index}" => item
  }
}
