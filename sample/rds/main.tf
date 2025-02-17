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

  # RDS configuration
  rds_config = [
    {
      create_global_cluster = var.create_global_cluster
      cluster_application   = var.cluster_application                       
      engine                = var.engine                          
      engine_version        = var.engine_version          
      database_name         = var.database_name                 
      deletion_protection   = var.deletion_protection                         
      cluster_config = [
        {
          principal                       = var.principal                   
          region                          = var.aws_region_principal             
          engine_mode                     = var.engine_mode         
          manage_master_user_password     = var.manage_master_user_password                  
          master_password                 = var.master_password           
          master_username                 = var.master_username                
          vpc_security_group_ids          = ["xxxxxx"]
          subnet_ids                      = [data.aws_subnet.database_subnet_1.id, data.aws_subnet.database_subnet_2.id]       
          backup_retention_period         = var.backup_retention_period                       
          skip_final_snapshot             = var.skip_final_snapshot                  
          preferred_backup_window         = var.preferred_backup_window         
          storage_encrypted               = var.storage_encrypted                  
          kms_key_id                      = "xxxxxx"
          port                            = var.port                  
          service                         = var.service               
          enabled_cloudwatch_logs_exports = ["xxxxxx"]                      
          copy_tags_to_snapshot           = var.copy_tags_to_snapshot
          cluster_parameter = {
            family      = var.family                                  
            description = "Aurora MySQL 5.6 default cluster parameters"
            parameters  = ["xxxxxx"]
          }
          instance_parameter = {
            family      = var.family                                 
            parameters  = ["xxxxxx"]
          }
          cluster_instances = [
            {
              instance_class                        = var.instance_class
              publicly_accessible                   = var.publicly_accessible                
              auto_minor_version_upgrade            = var.auto_minor_version_upgrade                 
              performance_insights_enabled          = var.performance_insights_enabled                
              performance_insights_retention_period = var.performance_insights_retention_period                   
              monitoring_interval                   = var.monitoring_interval                   
            }
          ]
        }
      ]
    }
  ]
  depends_on = [module.kms, module.security_groups]
}