# PC-IAC-007: Outputs granulares — ARNs/IDs/endpoints (no objetos completos)
# PC-IAC-014: Splat expressions sobre values() para for_each maps

##############################################################
# Outputs — Cluster Principal
##############################################################

output "principal_cluster_arns" {
  description = "Mapa de ARNs de los clusters RDS principales. Clave: '{cluster_key}-{region}-{idx}'"
  value       = { for k, v in aws_rds_cluster.principal_cluster : k => v.arn }
}

output "principal_cluster_ids" {
  description = "Mapa de IDs (cluster_identifier) de los clusters RDS principales."
  value       = { for k, v in aws_rds_cluster.principal_cluster : k => v.id }
}

output "principal_cluster_endpoint" {
  description = "Endpoint de escritura del primer cluster principal (write endpoint)."
  value       = length(aws_rds_cluster.principal_cluster) > 0 ? values(aws_rds_cluster.principal_cluster)[0].endpoint : ""
}

output "principal_cluster_endpoints" {
  description = "Mapa de endpoints de escritura de todos los clusters principales."
  value       = { for k, v in aws_rds_cluster.principal_cluster : k => v.endpoint }
}

output "principal_cluster_reader_endpoint" {
  description = "Endpoint de lectura (reader) del primer cluster principal."
  value       = length(aws_rds_cluster.principal_cluster) > 0 ? values(aws_rds_cluster.principal_cluster)[0].reader_endpoint : ""
}

output "principal_cluster_reader_endpoints" {
  description = "Mapa de endpoints de lectura de todos los clusters principales."
  value       = { for k, v in aws_rds_cluster.principal_cluster : k => v.reader_endpoint }
}

output "principal_cluster_ports" {
  description = "Mapa de puertos de los clusters principales."
  value       = { for k, v in aws_rds_cluster.principal_cluster : k => v.port }
}

output "principal_cluster_database_names" {
  description = "Mapa de nombres de base de datos de los clusters principales."
  value       = { for k, v in aws_rds_cluster.principal_cluster : k => v.database_name }
}

output "principal_cluster_master_usernames" {
  description = "Mapa de usuarios maestros de los clusters principales."
  value       = { for k, v in aws_rds_cluster.principal_cluster : k => v.master_username }
}

##############################################################
# Outputs — Secrets Manager (contraseña gestionada por RDS)
##############################################################

output "principal_cluster_master_user_secret_arn" {
  description = "ARN del secret en Secrets Manager del primer cluster principal (cuando manage_master_user_password=true)."
  value = (
    length(aws_rds_cluster.principal_cluster) > 0
    ? try(values(aws_rds_cluster.principal_cluster)[0].master_user_secret[0].secret_arn, "")
    : ""
  )
}

output "principal_cluster_master_user_secrets" {
  description = "Mapa de ARNs de secrets de Secrets Manager para todos los clusters principales."
  value = {
    for k, v in aws_rds_cluster.principal_cluster : k => try(v.master_user_secret[0].secret_arn, "")
  }
}

##############################################################
# Outputs — Instancias Principales
##############################################################

output "principal_instance_arns" {
  description = "Mapa de ARNs de las instancias del cluster principal."
  value       = { for k, v in aws_rds_cluster_instance.principal_cluster_instances : k => v.arn }
}

output "principal_instance_endpoints" {
  description = "Mapa de endpoints de las instancias del cluster principal."
  value       = { for k, v in aws_rds_cluster_instance.principal_cluster_instances : k => v.endpoint }
}

##############################################################
# Outputs — Subnet Groups
##############################################################

output "principal_subnet_group_ids" {
  description = "Mapa de IDs de los subnet groups del cluster principal."
  value       = { for k, v in aws_db_subnet_group.principal_subnet_group : k => v.id }
}

##############################################################
# Outputs compatibles con versión anterior (deprecados — usar los mapa arriba)
# Mantenidos para no romper el transversal existente
##############################################################

output "rds_cluster_arn" {
  description = "[Compat] Lista de ARNs del cluster principal. Usar principal_cluster_arns para acceso por clave."
  value       = values(aws_rds_cluster.principal_cluster)[*].arn
}

output "rds_cluster_id" {
  description = "[Compat] Lista de IDs del cluster principal."
  value       = values(aws_rds_cluster.principal_cluster)[*].id
}

output "rds_cluster_endpoint" {
  description = "[Compat] Lista de endpoints del cluster principal."
  value       = values(aws_rds_cluster.principal_cluster)[*].endpoint
}

output "rds_cluster_reader_endpoint" {
  description = "[Compat] Lista de reader endpoints del cluster principal."
  value       = values(aws_rds_cluster.principal_cluster)[*].reader_endpoint
}

output "rds_cluster_port" {
  description = "[Compat] Lista de puertos del cluster principal."
  value       = values(aws_rds_cluster.principal_cluster)[*].port
}

output "rds_cluster_resource_id" {
  description = "[Compat] Lista de Resource IDs del cluster principal."
  value       = values(aws_rds_cluster.principal_cluster)[*].cluster_resource_id
}

output "rds_cluster_master_user_secret" {
  description = "[Compat] Lista de master_user_secret blocks del cluster principal."
  value       = try(values(aws_rds_cluster.principal_cluster)[*].master_user_secret, null)
}


