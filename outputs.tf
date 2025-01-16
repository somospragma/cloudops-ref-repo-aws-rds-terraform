output "rds_cluster_arn" {
  value = [for cluster in aws_rds_cluster.principal_cluster : cluster.arn]
  description = "ARN del clúster RDS principal"
}
