output "rds_cluster_arn" {
  value       = [for cluster in aws_rds_cluster.principal_cluster : cluster.arn]
  description = "ARN of principal cluster RDS"
}

output "rds_cluster_id" {
  value       = [for cluster in aws_rds_cluster.principal_cluster : cluster.id]
  description = "id of principal cluster RDS"
}

output "rds_cluster_endpoint" {
  value       = [for cluster in aws_rds_cluster.principal_cluster : cluster.endpoint]
  description = "endpoint of principal cluster RDS"
}

output "rds_cluster_port" {
  value       = [for cluster in aws_rds_cluster.principal_cluster : cluster.port]
  description = "port of principal cluster RDS"
}

output "rds_cluster_resource_id" {
  value       = [for cluster in aws_rds_cluster.principal_cluster : cluster.cluster_resource_id]
  description = "Cluster Resource ID of principal cluster RDS"
}

output "rds_cluster_master_user_secret" {
  description = "The generated database master user secret when `manage_master_user_password` is set to `true`"
  value       = try([for cluster in aws_rds_cluster.principal_cluster : cluster.master_user_secret], null)
}