###########################################
############### RDS module ################
###########################################

module "rds-aurora" {
  source = "../../"
  
  providers = {
    aws.principal = aws.principal          #Write manually alias (the same alias name configured in providers.tf)
    aws.secondary = aws.secondary          #Write manually alias (the same alias name configured in providers.tf)
  }

  # Common configuration
  environment = var.environment
  client      = var.client
  project     = var.project
  service     = var.service

  #master_password = jsondecode(data.aws_secretsmanager_secret_version.current_p.secret_string)["password"]
  master_password = ""

  # RDS configuration
  rds_config = [
    {
      create_global_cluster = var.create_global_cluster
      cluster_application   = var.cluster_application                       
      engine                = var.engine                          
      engine_version        = var.engine_version          
      database_name         = var.database_name                 
      deletion_protection   = var.deletion_protection
      storage_encrypted     = var.storage_encrypted
      serverless_deploy     = var.serverless_deploy                         
      cluster_config = [
        {
          principal                       = var.principal                   
          region                          = var.aws_region_principal             
          engine_mode                     = var.engine_mode         
          manage_master_user_password     = var.manage_master_user_password                  
          master_password                 = ""           
          master_username                 = var.master_username                
          vpc_security_group_ids          = [data.aws_security_group.rds_security_group_p.id]
          subnet_ids                      = [data.aws_subnet.database_subnet_1_p.id, data.aws_subnet.database_subnet_2_p.id]       
          backup_retention_period         = var.backup_retention_period                       
          skip_final_snapshot             = var.skip_final_snapshot                  
          preferred_backup_window         = var.preferred_backup_window                           
          kms_key_id                      = var.kms_key_id_principal
          port                            = var.port                  
          service                         = var.service               
          enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports                    
          copy_tags_to_snapshot           = var.copy_tags_to_snapshot
          cluster_parameter = {
            family      = var.family                                  
            description = "Aurora PostgreSQL 16.6 default cluster parameters"
            parameters  = []
          }
          cluster_scaling_configuration = {
            max_capacity             = var.scaling_max_capacity
            min_capacity             = var.scaling_min_capacity
            seconds_until_auto_pause = var.scaling_seconds_until_auto_pause
          }
          instance_parameter = {
            family      = var.family                                 
            parameters  = []
          }
          cluster_instances = [
            {
              record_id                             = "instance_1"
              instance_class                        = var.instance_class
              publicly_accessible                   = var.publicly_accessible                
              auto_minor_version_upgrade            = var.auto_minor_version_upgrade                 
              performance_insights_enabled          = var.performance_insights_enabled                
              performance_insights_retention_period = var.performance_insights_retention_period                   
              monitoring_interval                   = var.monitoring_interval
              monitoring_role_arn                   = var.monitoring_role_arn                    
            }
          ]
        }
      ]
    }
  ]
  #depends_on = [module.kms, module.security_groups]
}