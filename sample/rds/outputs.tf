# PC-IAC-007: Outputs granulares — exponer IDs y endpoints para validar el despliegue

output "rds_cluster_endpoints" {
  description = "Endpoints de escritura de los clusters desplegados."
  value       = module.rds.principal_cluster_endpoints
}

output "rds_cluster_reader_endpoints" {
  description = "Endpoints de lectura de los clusters desplegados."
  value       = module.rds.principal_cluster_reader_endpoints
}

output "rds_cluster_arns" {
  description = "ARNs de los clusters desplegados."
  value       = module.rds.principal_cluster_arns
}

output "rds_cluster_master_user_secret_arns" {
  description = "ARNs de los secrets en Secrets Manager (contraseña maestra gestionada por RDS)."
  value       = module.rds.principal_cluster_master_user_secrets
}

output "rds_subnet_group_ids" {
  description = "IDs de los subnet groups creados."
  value       = module.rds.principal_subnet_group_ids
}
