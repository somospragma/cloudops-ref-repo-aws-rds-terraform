################################################################
# Module VPC Security Groups
################################################################

module "security_groups" {
  source = "git::https://github.com/somospragma/cloudops-ref-repo-aws-sg-terraform.git?ref=feature/sg-module-init"
  providers = {
    aws.project = aws.pra_idp_dev
  }
  client      = var.client
  project     = var.project
  environment = var.environment
  sg_config = [
    {
      application = "sm"
      description = "Security group for VPC Endpoint"
      vpc_id      = data.aws_vpc.vpc_hefesto.id

      ingress = [
        {
          from_port       = 3306
          to_port         = 3306
          protocol        = "tcp"
          cidr_blocks     = ["0.0.0.0/0"]
          security_groups = []
          prefix_list_ids = []
          self            = false
          description     = "Allow HTTPS inbound"
        }
      ]

      egress = [
        {
          from_port       = 0
          to_port         = 0
          protocol        = "-1"
          cidr_blocks     = ["0.0.0.0/0"]
          prefix_list_ids = []
          description     = "Allow all outbound traffic"
        }
      ]
    }
  ]
}

################################################################
# Module RDS
################################################################

module "rds-aurora" {
  source = "./module/rds-aurora"
  
  providers = {
    aws.principal = aws.pra_idp_dev
    aws.secondary = aws.pra_idp_dev_2
  }
  environment = var.environment
  client      = var.client
  service     = var.service_name_rds


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
        region                          = var.aws_region             
        engine_mode                     = var.engine_mode         
        manage_master_user_password     = var.manage_master_user_password                  
        master_password                 = var.master_password           
        master_username                 = var.master_username                
        vpc_security_group_ids          = [module.security_groups.sg_info["sm"].sg_id]
        #vpc_security_group_ids          = []
        subnet_ids                      = [data.aws_subnet.database_subnet_1.id, data.aws_subnet.database_subnet_2.id]       
        backup_retention_period         = var.backup_retention_period                       
        skip_final_snapshot             = var.skip_final_snapshot                  
        preferred_backup_window         = var.preferred_backup_window         
        storage_encrypted               = var.storage_encrypted                  
        kms_key_id                      = module.kms.kms_info[0]["key_arn"]
        #kms_key_id                      = var.kms_key_id
        port                            = var.port                  
        service                         = var.service               
        enabled_cloudwatch_logs_exports = []                      
        copy_tags_to_snapshot           = var.copy_tags_to_snapshot
        cluster_parameter = {
          family      = var.family                                  
          description = "Aurora MySQL 5.6 default cluster parameters"
          parameters = []
        }
        instance_parameter = {
          family      = var.family                                 
          parameters  = []
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

################################################################
# Module KMS
################################################################
module "kms" {
  source = "./module/kms"

  client      = var.client
  service     = var.service_name_kms
  environment = var.environment

  kms_config = [
    {
      description         = "Key for securing RDS cluster data"
      enable_key_rotation = var.enable_key_rotation
      statements = [
        {
          sid         = "AllowRDSAccess"
          actions     = ["kms:Encrypt", "kms:Decrypt", "kms:GenerateDataKey"]
          resources   = ["*"]
          effect      = "Allow"
          type        = "AWS"
          identifiers = [
            "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
          ]
          condition = []
        }
      ]
      application_id = "${var.project}"
    }
  ]
}
  
