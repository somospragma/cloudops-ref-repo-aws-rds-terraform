# PC-IAC-002: Variables con type, description y validation obligatorios
# PC-IAC-002/PC-IAC-010: map(object) en lugar de list(object) para estabilidad en for_each

##############################################################
# Variables Globales de Gobernanza
##############################################################
variable "environment" {
  type        = string
  description = "Entorno de despliegue (dev, qa, pdn)"
  validation {
    condition     = contains(["dev", "qa", "pdn", "staging", "prod"], var.environment)
    error_message = "El entorno debe ser uno de: dev, qa, pdn, staging, prod."
  }
}

variable "client" {
  type        = string
  description = "Nombre del cliente — usado en la nomenclatura {client}-{project}-{environment}-..."
  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 10
    error_message = "El nombre del cliente debe tener entre 1 y 10 caracteres."
  }
}

variable "project" {
  type        = string
  description = "Nombre del proyecto — usado en la nomenclatura"
  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 15
    error_message = "El nombre del proyecto debe tener entre 1 y 15 caracteres."
  }
}

variable "service" {
  type        = string
  description = "Nombre del servicio — sufijo en la nomenclatura (ej: db, backend, analytics)"
  validation {
    condition     = length(var.service) > 0
    error_message = "El nombre del servicio no puede estar vacío."
  }
}

variable "master_password" {
  type        = string
  description = "Contraseña maestra del cluster. Solo requerida si manage_master_user_password=false. Usar Secrets Manager cuando sea posible."
  sensitive   = true
  default     = ""
}

##############################################################
# Variables RDS
# PC-IAC-002: map(object) para estabilidad en for_each
# PC-IAC-010: cluster_scaling_configuration optional — solo requerido cuando serverless_deploy=true
##############################################################
variable "rds_config" {
  type = map(object({
    # ---- Configuración del cluster (nivel global) ----
    create_global_cluster = bool
    engine                = string
    engine_version        = string
    database_name         = string
    deletion_protection   = bool
    storage_encrypted     = optional(bool, true)
    # true  → Aurora Serverless v2 (engine_mode=provisioned + db.serverless + serverlessv2_scaling_configuration)
    # false → Instancia provisionada (ej: db.t3.medium, db.r6g.large, etc.)
    serverless_deploy = optional(bool, false)

    cluster_config = list(object({
      principal   = bool
      region      = string
      engine_mode = string # "provisioned" para ambos modos (serverless v2 e instancia normal)

      # ---- Autenticación ----
      manage_master_user_password = optional(bool, true)
      master_password             = optional(string, "")
      master_username             = string

      # ---- Red (inyectados por los locals del root) ----
      vpc_security_group_ids = optional(list(string), [])
      subnet_ids             = optional(list(string), [])

      # ---- Backup y mantenimiento ----
      backup_retention_period = number
      skip_final_snapshot     = optional(bool, true)
      preferred_backup_window = string

      # ---- Cifrado ----
      storage_encrypted = optional(bool, true)
      kms_key_id        = optional(string, "")

      # ---- Rendimiento ----
      port                            = string
      service                         = string
      enabled_cloudwatch_logs_exports = list(string)
      copy_tags_to_snapshot           = optional(bool, true)
      enable_http_endpoint            = optional(bool, false)

      # ---- Parámetros ----
      cluster_parameter = object({
        family      = string
        description = string
        parameters = list(object({
          name         = string
          value        = string
          apply_method = string
        }))
      })

      # PC-IAC-010: optional — solo se usa cuando serverless_deploy=true
      # Para instancia provisionada (serverless_deploy=false) dejar en null o no declarar
      cluster_scaling_configuration = optional(object({
        max_capacity             = number
        min_capacity             = number
        seconds_until_auto_pause = optional(number, 3600)
      }), null)

      instance_parameter = object({
        family = string
        parameters = list(object({
          name         = string
          value        = string
          apply_method = string
        }))
      })

      cluster_instances = list(object({
        record_id              = optional(string, "instance-1")
        instance_class         = string # "db.serverless" para SLv2, "db.t3.medium" etc para provisioned
        publicly_accessible    = optional(bool, false)
        auto_minor_version_upgrade = optional(bool, true)
        # CORRECCIÓN: performance_insights solo disponible en ciertos instance_class
        # db.t3.medium NO soporta PI — poner false en ese caso
        performance_insights_enabled          = optional(bool, false)
        performance_insights_retention_period = optional(number, 7)
        # CORRECCIÓN: kms_key solo se pasa cuando performance_insights_enabled=true
        performance_insights_kms_key_id = optional(string, "")
        monitoring_interval             = optional(number, 0)
        monitoring_role_arn             = optional(string, "")
      }))
    }))
  }))
  description = <<EOF
Mapa de configuración de clusters Aurora RDS. Usa map(object) para estabilidad en for_each (PC-IAC-002/010).

MODOS DE DESPLIEGUE:
  serverless_deploy = true  → Aurora Serverless v2
    - engine_mode = "provisioned"
    - instance_class = "db.serverless"
    - cluster_scaling_configuration REQUERIDO (max_capacity, min_capacity)
    - performance_insights_enabled = true (soportado en db.serverless)

  serverless_deploy = false → Instancia provisionada
    - engine_mode = "provisioned"
    - instance_class = "db.t3.medium" / "db.r6g.large" / etc.
    - cluster_scaling_configuration = null (ignorado)
    - performance_insights_enabled = false para db.t3.micro/medium (no soportado)

NOMENCLATURA: {client}-{project}-{environment}-cluster-{key}-{service}

EJEMPLOS en sample/terraform.tfvars
EOF
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.rds_config : contains(["aurora-mysql", "aurora-postgresql"], v.engine)
    ])
    error_message = "El engine debe ser 'aurora-mysql' o 'aurora-postgresql'."
  }

  validation {
    condition = alltrue([
      for k, v in var.rds_config :
      !v.serverless_deploy || alltrue([
        for cc in v.cluster_config :
        cc.cluster_scaling_configuration != null
      ])
    ])
    error_message = "Cuando serverless_deploy=true, cluster_scaling_configuration es obligatorio en cada cluster_config."
  }
}
