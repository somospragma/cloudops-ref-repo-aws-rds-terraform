variable "rds_config" {
  type = list(object({
    create_global_cluster = bool
    cluster_application   = string
    engine                = string
    engine_version        = string
    database_name         = string
    deletion_protection   = bool
    cluster_config = list(object({
      principal                       = bool
      region                          = string
      engine_mode                     = string
      manage_master_user_password     = bool
      master_password                 = optional(string) //If manage_master_user_password is true, you cannot set any value
      master_username                 = string
      vpc_security_group_ids          = list(string)
      subnet_ids                      = list(string)
      backup_retention_period         = number
      skip_final_snapshot             = bool
      preferred_backup_window         = string
      storage_encrypted               = bool
      kms_key_id                      = string
      port                            = string
      service                         = string
      enabled_cloudwatch_logs_exports = list(string)
      copy_tags_to_snapshot           = bool
      cluster_parameter = object({
        family      = string
        description = string
        parameters = list(object({
          name         = string
          value        = string
          apply_method = string
        }))
      })
      instance_parameter = object({
        family = string
        parameters = list(object({
          name         = string
          value        = string
          apply_method = string
        }))
      })
      cluster_instances = list(object({
        instance_class                        = string
        publicly_accessible                   = bool
        auto_minor_version_upgrade            = bool
        performance_insights_enabled          = bool
        performance_insights_retention_period = number
        monitoring_interval                   = number
      }))
    }))
  }))
}

variable "service" {
  type = string
}

variable "client" {
  type = string
  description = "Client name"
}

variable "environment" {
  type = string
  description = "Environment where resources will be deployed"
}

variable "project" {
  type = string  
  description = "Project name"
}