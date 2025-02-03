###########################################
########## Common variables ###############
###########################################

variable "profile" {
  type = string
  description = "Profile name containing the access credentials to deploy the infrastructure on AWS"
}

variable "common_tags" {
    type = map(string)
    description = "Common tags to be applied to the resources"
}

variable "aws_region_principal" {
  type = string
  description = "AWS region where resources will be deployed"
}

variable "aws_region_secondary" {
  type = string
  description = "AWS region where resources will be deployed"
}

variable "environment" {
  type = string
  description = "Environment where resources will be deployed"
}

variable "client" {
  type = string
  description = "Client name"
}

variable "project" {
  type = string  
  description = "Project name"
}

variable "service" {
  type = string
  description = "Service name"
}

###########################################
############# RDS variables ###############
###########################################

variable "create_global_cluster" {
  type = bool 
  description = "If true, a global cluster will be created"
}

variable "cluster_application" {
  type = string  
  description = "Cluster application name"
}

variable "engine" {
  type = string  
  description = "Name of the database engine to be used for this DB cluster. Valid Values: aurora-mysql, aurora-postgresql, mysql, postgres. (Note that mysql and postgres are Multi-AZ RDS clusters)."
}

variable "engine_version" {
  type = string  
  description = "Database engine version."
}

variable "database_name" {
  type = string  
  description = "Data base name"
}

variable "deletion_protection" {
  type = bool  
  description = "If the DB cluster should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false."
}

variable "principal" {
  type = bool 
  description = "If true, it'll be deploy only one node."
}

variable "engine_mode" {
  type = string
  description = "Database engine mode. Valid values: global (only valid for Aurora MySQL 1.21 and earlier), parallelquery, provisioned, serverless. Defaults to: provisioned. See the RDS User Guide for limitations when using serverless."
}

variable "manage_master_user_password" {
  type = bool
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if master_password is provided."
}

variable "master_password" {
  type    = string
  default = null
  description = "(Required unless manage_master_user_password is set to true or unless a snapshot_identifier or replication_source_identifier is provided or unless a global_cluster_identifier is provided when the cluster is the 'secondary' cluster of a global database) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the RDS Naming Constraints. Cannot be set if manage_master_user_password is set to true."
}

variable "master_username" {
  type = string
  description = "Master username for the database"
}

variable "backup_retention_period" {
  type = number
  description = "Days to retain backups for. Default 1."
}

variable "skip_final_snapshot" {
  type = bool
  description = "Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false."
}

variable "preferred_backup_window" {
  type = string
  description = "Daily time range during which the backups happen"
}

variable "storage_encrypted" {
  type = bool
  description = "Service"
}

variable "kms_key_id" {
  type = string
  description = "Amazon Web Services KMS key identifier that is used to encrypt the secret."
}
variable "port" {
  type = string
  description = "Database port "
}

variable "copy_tags_to_snapshot" {
  type = string
  description = "Copy all Cluster tags to snapshots. Default is false."
}

variable "family" {
  type = string
  description = "The family of the DB cluster parameter group."
}

variable "instance_class" {
  type = string
  description = "Instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora uses db.* instance classes/types. Please see AWS Documentation for currently available instance classes and complete details. For Aurora Serverless v2 use db.serverless."
}

variable "publicly_accessible" {
  type = bool
  description = "Bool to control if instance is publicly accessible. Default false. See the documentation on Creating DB Instances for more details on controlling this property."
}

variable "auto_minor_version_upgrade" {
  type = bool
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default true."
}

variable "performance_insights_enabled" {
  type = bool
  description = "Specifies whether Performance Insights is enabled or not. NOTE: When Performance Insights is configured at the cluster level through aws_rds_cluster, this argument cannot be set to a value that conflicts with the cluster's configuration."
}

variable "performance_insights_retention_period" {
  type    = number
  default = null
  description = "Specifies the amount of time to retain performance insights data for. Defaults to 7 days if Performance Insights are enabled. Valid values are 7, month * 31 (where month is a number of months from 1-23), and 731."
}

variable "monitoring_interval" {
  type = number
  description = "Interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
}
