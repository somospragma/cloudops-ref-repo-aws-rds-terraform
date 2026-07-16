# PC-IAC-002: Variables con type, description y validation
# PC-IAC-026: Variables del sample reciben la config base sin IDs — locals.tf inyecta los dinámicos

##############################################################
# Gobernanza
##############################################################
variable "profile" {
  type        = string
  description = "Profile de ~/.aws/credentials para autenticación local. En CI/CD usar OIDC."
}

variable "aws_region_principal" {
  type        = string
  description = "Región AWS principal donde se despliega el cluster."
  validation {
    condition     = length(var.aws_region_principal) > 0
    error_message = "La región principal no puede estar vacía."
  }
}

variable "aws_region_secondary" {
  type        = string
  description = "Región AWS secundaria (para clusters multi-región). Usar la misma región si no se necesita multi-región."
}

variable "environment" {
  type        = string
  description = "Entorno de despliegue."
  validation {
    condition     = contains(["dev", "qa", "pdn", "staging", "prod"], var.environment)
    error_message = "Entorno debe ser: dev, qa, pdn, staging o prod."
  }
}

variable "client" {
  type        = string
  description = "Nombre del cliente — parte de la nomenclatura {client}-{project}-{environment}-..."
  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 10
    error_message = "El cliente debe tener entre 1 y 10 caracteres."
  }
}

variable "project" {
  type        = string
  description = "Nombre del proyecto."
  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 15
    error_message = "El proyecto debe tener entre 1 y 15 caracteres."
  }
}

variable "service" {
  type        = string
  description = "Nombre del servicio — sufijo en la nomenclatura (ej: db)."
}

variable "common_tags" {
  type        = map(string)
  description = "Tags comunes aplicados a todos los recursos vía default_tags del provider."
  default     = {}
}

##############################################################
# RDS — map(object) para estabilidad en for_each (PC-IAC-002/010)
# IDs vacíos son inyectados por locals.tf desde data sources (PC-IAC-026)
##############################################################
variable "rds_config" {
  type = map(object({
    create_global_cluster = bool
    engine                = string
    engine_version        = string
    database_name         = string
    deletion_protection   = bool
    storage_encrypted     = optional(bool, true)
    serverless_deploy     = optional(bool, false)
    cluster_config = list(object({
      principal                       = bool
      region                          = string
      engine_mode                     = string
      manage_master_user_password     = optional(bool, true)
      master_password                 = optional(string, "")
      master_username                 = string
      vpc_security_group_ids          = optional(list(string), [])
      subnet_ids                      = optional(list(string), [])
      backup_retention_period         = number
      skip_final_snapshot             = optional(bool, true)
      preferred_backup_window         = string
      storage_encrypted               = optional(bool, true)
      kms_key_id                      = optional(string, "")
      port                            = string
      service                         = string
      enabled_cloudwatch_logs_exports = list(string)
      copy_tags_to_snapshot           = optional(bool, true)
      enable_http_endpoint            = optional(bool, false)
      cluster_parameter = object({
        family      = string
        description = string
        parameters  = list(object({ name = string, value = string, apply_method = string }))
      })
      cluster_scaling_configuration = optional(object({
        max_capacity             = number
        min_capacity             = number
        seconds_until_auto_pause = optional(number, 3600)
      }), null)
      instance_parameter = object({
        family     = string
        parameters = list(object({ name = string, value = string, apply_method = string }))
      })
      cluster_instances = list(object({
        record_id                             = optional(string, "instance-1")
        instance_class                        = string
        publicly_accessible                   = optional(bool, false)
        auto_minor_version_upgrade            = optional(bool, true)
        performance_insights_enabled          = optional(bool, false)
        performance_insights_retention_period = optional(number, 7)
        performance_insights_kms_key_id       = optional(string, "")
        monitoring_interval                   = optional(number, 0)
        monitoring_role_arn                   = optional(string, "")
      }))
    }))
  }))
  description = "Mapa de clusters Aurora RDS. Ver terraform.tfvars.sample para ejemplos de ambos modos."
  default     = {}
}
