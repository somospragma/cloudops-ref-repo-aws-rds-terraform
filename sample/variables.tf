##################################################
# Variable Globales
##################################################
variable "client" {
  type = string
}
variable "environment" {
  type = string
}
variable "aws_region" {
  type = string
}
variable "profile" {
  type = string
}
variable "common_tags" {
    type = map(string)
    description = "Tags comunes aplicadas a los recursos"
}
variable "project" {
  type = string  
}
variable "service_name_rds"{
  type = string  
}
variable "service_name_kms"{
  type = string  
}

##################################################
# Variable RDS
##################################################

variable "create_global_cluster" {
  type = bool 
}
variable "cluster_application" {
  type = string  
}
variable "engine" {
  type = string  
}
variable "engine_version" {
  type =string  
}
variable "database_name" {
  type =string  
}
variable "deletion_protection" {
  type =bool  
}
variable "principal" {
  type =bool 
}
variable "engine_mode" {
  type =string
}
variable "manage_master_user_password" {
  type =bool
}
variable "master_password" {
  type    = string
  default = null
}
variable "master_username" {
  type =string
}
variable "backup_retention_period" {
  type =number
}
variable "skip_final_snapshot" {
  type =bool
}
variable "preferred_backup_window" {
  type =string
}
variable "storage_encrypted" {
  type =bool
}
variable "kms_key_id" {
  type =string
}
variable "port" {
  type =string
}
variable "service" {
  type =string
}
variable "copy_tags_to_snapshot" {
  type =string
}
variable "family" {
  type =string
}
variable "instance_class" {
  type =string
}
variable "publicly_accessible" {
  type =bool
}
variable "auto_minor_version_upgrade" {
  type =bool
}
variable "performance_insights_enabled" {
  type =bool
}
variable "performance_insights_retention_period" {
  type    = number
  default = null
}
variable "monitoring_interval" {
  type =number
}


##################################################
# Variable KMS
##################################################
variable "enable_key_rotation" {
  type =bool
}
