###############################################################
# Variables Globales
###############################################################


aws_region        = "us-east-1"
profile           = "pra_idp_dev"
environment       = "dev"
client            = "pragma"
project           = "hefesto"
service_name_rds  = "rds"
service_name_kms  = "kms"


common_tags = {
  environment   = "dev"
  project-name  = "Modulos Referencia"
  cost-center   = "-"
  owner         = "cristian.noguera@pragma.com.co"
  area          = "KCCC"
  provisioned   = "terraform"
  datatype      = "interno"
}


###############################################################
# Variables RDS
###############################################################

create_global_cluster = false                              # No crear un global cluster
cluster_application   = "hefesto"                          # Nombre de aplicacion
engine                = "aurora-mysql"                     # Motor de base de datos Aurora MySQL
engine_version        = "5.7.mysql_aurora.2.12.4"          # (Aurora MySQL 5.7)
database_name         = "hefesto"                          # Nombre de la base de datos
deletion_protection   = false                              # No habilitar protección contra eliminación


principal                       = true                    # Nodo principal del clúster
region                          = "us-east-1"             # Región de menor costo
engine_mode                     = "provisioned"           # Modo provisionado
manage_master_user_password     = true                    # Gestionar la contraseña del master
#master_password                = "hefesto2025"           # Contraseña de usuario master solo si manage_master_user_password este en falso
master_username                 = "admin"                 # Usuario admin
backup_retention_period         = 7                       # Retención de copias de seguridad por 7 días
skip_final_snapshot             = true                    # No tomar snapshot final
preferred_backup_window         = "00:00-00:30"           # Ventana de backup
storage_encrypted               = true                    # No cifrado de almacenamiento
kms_key_id                      = ""                      # Clave KMS predeterminada
port                            = "3306"                  # Puerto de MySQL
service                         = "default"               # Servicio predeterminado
enabled_cloudwatch_logs_exports = []                      # exportar logs a CloudWatch
copy_tags_to_snapshot           = true                    # copiar etiquetas a los snapshots
family                          = "aurora5.7"             # Familia de parámetros para Aurora MySQL 5.7


instance_class                        = "db.r5.large"        # Instancia económica (puedes cambiar a db.t3.micro si lo prefieres)
publicly_accessible                   = false                # No exponer públicamente la instancia
auto_minor_version_upgrade            = true                 # Actualizaciones automáticas
performance_insights_enabled          = false                # Deshabilitar Performance Insights
#performance_insights_retention_period = 7                   # Mantener 7 días de datos de rendimiento
monitoring_interval                   = 0   


# KMS
enable_key_rotation                   = false