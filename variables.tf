###########################################
########## Common variables ###############
###########################################

variable "environment" {
  type        = string
  description = "Environment where resources will be deployed"
}

variable "client" {
  type        = string
  description = "Client name"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "service" {
  type = string
  description = "Service name"
}

###########################################
############# RDS variables ###############
###########################################

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
      master_password                 = optional(string)
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
  description = <<EOF
    - create_global_cluster: (string) If true, a global cluster will be created.
    - cluster_application: (string) Cluster application name.
    - engine: (string) Name of the database engine to be used for this DB cluster. Valid Values: aurora-mysql, aurora-postgresql, mysql, postgres. (Note that mysql and postgres are Multi-AZ RDS clusters).
    - engine_version: (string) Database engine version.
    - database_name: (string) Data base name.
    - deletion_protection: (bool) If the DB cluster should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false.
    - cluster_config.principal: (bool) If true, it'll be deploy only one node.
    - cluster_config.engine_mode: (string) Database engine mode. Valid values: global (only valid for Aurora MySQL 1.21 and earlier), parallelquery, provisioned, serverless. Defaults to: provisioned. See the RDS User Guide for limitations when using serverless.
    - cluster_config.manage_master_user_password: (bool) Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if master_password is provided.
    - cluster_config.master_password: (optional, string) (Required unless manage_master_user_password is set to true or unless a snapshot_identifier or replication_source_identifier is provided or unless a global_cluster_identifier is provided when the cluster is the "secondary" cluster of a global database) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the RDS Naming Constraints. Cannot be set if manage_master_user_password is set to true.
    - cluster_config.master_username: (string) Master username for the database
    - cluster_config.backup_retention_period: (number) Days to retain backups for. Default 1.
    - cluster_config.skip_final_snapshot: (bool) Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false.
    - cluster_config.preferred_backup_window: (string) Daily time range during which the backups happen
    - cluster_config.storage_encrypted: (bool) Specifies whether the DB cluster is encrypted.
    - cluster_config.kms_key_id: (string) Amazon Web Services KMS key identifier that is used to encrypt the secret.
    - cluster_config.port: (string) Database port.
    - cluster_config.service: (string) Service name.
    - cluster_config.enabled_cloudwatch_logs_exports: (list(string)) Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql (PostgreSQL).
    - cluster_config.copy_tags_to_snapshot: (bool) Copy all Cluster tags to snapshots. Default is false.
    - cluster_parameter.family: (string) The family of the DB cluster parameter group. 
    - instance_parameter.family: (string) The family of the DB parameter group. 
    - cluster_instances.instance_class: (string) Instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora uses db.* instance classes/types. Please see AWS Documentation for currently available instance classes and complete details. For Aurora Serverless v2 use db.serverless.
    - cluster_instances.publicly_accessible: (bool) Bool to control if instance is publicly accessible. Default false. See the documentation on Creating DB Instances for more details on controlling this property.
    - cluster_instances.auto_minor_version_upgrade: (bool) Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default true.
    - cluster_instances.performance_insights_enabled: (bool) Specifies whether Performance Insights is enabled or not. NOTE: When Performance Insights is configured at the cluster level through aws_rds_cluster, this argument cannot be set to a value that conflicts with the cluster's configuration.
    - cluster_instances.performance_insights_retention_period: (number) Specifies the amount of time to retain performance insights data for. Defaults to 7 days if Performance Insights are enabled. Valid values are 7, month * 31 (where month is a number of months from 1-23), and 731.
    - cluster_instances.monitoring_interval: (number) Interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60.
  EOF
}

