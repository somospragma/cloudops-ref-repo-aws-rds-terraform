# **Módulo Terraform: cloudops-ref-repo-aws-rds-terraform**

## Descripción:

Este módulo facilita la creación de una base de datos RDS, el cual requiere de los siguientes recursos, los cuales debieron ser previamente creados:

- vpc_security_group_ids: Ids of security groups.
- subnet_ids: Ids of subnets.
- kms_key_id: Id of KMS.

Consulta CHANGELOG.md para la lista de cambios de cada versión. *Recomendamos encarecidamente que en tu código fijes la versión exacta que estás utilizando para que tu infraestructura permanezca estable y actualices las versiones de manera sistemática para evitar sorpresas.*

## Estructura del Módulo

El módulo cuenta con la siguiente estructura:

```bash
cloudops-ref-repo-aws-rds-terraform/
└── sample/rds
    ├── data.tf
    ├── main.tf
    ├── outputs.tf
    ├── providers.tf
    ├── terraform.tfvars.sample
    └── variables.tf
├── .gitignore
├── CHANGELOG.md
├── data.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── README.md
├── variables.tf
```

- Los archivos principales del módulo (`data.tf`, `main.tf`, `outputs.tf`, `variables.tf`, `providers.tf`) se encuentran en el directorio raíz.
- `CHANGELOG.md` y `README.md` también están en el directorio raíz para fácil acceso.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.

## Seguridad & Cumplimiento
 
Consulta a continuación la fecha y los resultados de nuestro escaneo de seguridad y cumplimiento.

<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description | 
| --------- | ---- | ------- | ----------- | 
| ![checkov](https://img.shields.io/badge/checkov-passed-green) | 2023-09-20 | 3.2.232 | Escaneo profundo del plan de Terraform en busca de problemas de seguridad y cumplimiento |
<!-- END_BENCHMARK_TABLE -->
 
## Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
sample/rds/providers.tf
provider "aws" {
  alias = "principal"
  # ... otras configuraciones del provider
}

sample/rds/main.tf
module "rds" {
  source = ""
  providers = {
    aws.project = aws.principal
  }
  # ... resto de la configuración
}
```

## Uso del Módulo:

```hcl
module "rds" {
  source = ""
  
  providers = {
    aws.principal = aws.principal
    aws.secondary = aws.secondary
  }

  # Common configuration 
  profile     = "profile01"
  aws_region  = "us-east-1"
  environment = "dev"
  client      = "cliente01"
  project     = "proyecto01"
  common_tags = {
    environment   = "dev"
    project-name  = "proyecto01"
    cost-center   = "xxxxxx"
    owner         = "xxxxxx"
    area          = "xxxxxx"
    provisioned   = "xxxxxx"
    datatype      = "xxxxxx"
  }

  # RDS configuration 
  rds_config = [
    {
      create_global_cluster = "xxxxxx"
      cluster_application   = "xxxxxx"                     
      engine                = "xxxxxx"           
      engine_version        = "xxxxxx"   
      database_name         = "xxxxxx"         
      deletion_protection   = "xxxxxx"                       
      cluster_config = [
        {
          principal                       = "xxxxxx"        
          region                          = "xxxxxx"   
          engine_mode                     = "xxxxxx"
          manage_master_user_password     = "xxxxxx"                  
          master_password                 = "xxxxxx"      
          master_username                 = "xxxxxx"           
          vpc_security_group_ids          = ["xxxxxx"]
          subnet_ids                      = ["xxxxxx", "xxxxxx"]       
          backup_retention_period         = "xxxxxx"                       
          skip_final_snapshot             = "xxxxxx"                     
          preferred_backup_window         = "xxxxxx"            
          storage_encrypted               = "xxxxxx"                     
          kms_key_id                      = ["xxxxxx"]   
          port                            = "xxxxxx"                   
          service                         = "xxxxxx"                  
          enabled_cloudwatch_logs_exports = ["xxxxxx"]                  
          copy_tags_to_snapshot           = "xxxxxx"   
          cluster_parameter = {
            family      = "xxxxxx"                                   
            description = "xxxxxx"
            parameters  = ["xxxxxx"]
          }
          instance_parameter = {
            family      = "xxxxxx"                                   
            parameters  = ["xxxxxx"]
          }
          cluster_instances = [
            {
              instance_class                        = "xxxxxx" 
              publicly_accessible                   = "xxxxxx"                 
              auto_minor_version_upgrade            = "xxxxxx"                  
              performance_insights_enabled          = "xxxxxx"                 
              performance_insights_retention_period = "xxxxxx"                    
              monitoring_interval                   = "xxxxxx"                    
            }
          ]
        }
      ]
    }
  ]
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.31.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 4.31.0 |

## Resources

| Name | Type |
|------|------|
| [aws_rds_global_cluster.global_db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_global_cluster) | resource |
| [aws_rds_cluster.principal_cluster/secondary_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.principal_cluster_instances/secondary_cluster_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_db_subnet_group.principal_subnet_group/secondary_subnet_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_db_parameter_group.principal_parameter/secondary_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_rds_cluster_parameter_group.principal_parameter/secondary_parameter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="create_global_cluster"></a> [create_global_cluster](#input\_create_global_cluster_) | If true, a global cluster will be created. | `bool` | n/a | yes |
| <a name="cluster_application"></a> [cluster_application](#input\_cluster_application_) | Cluster application name. | `string` | n/a | yes |
| <a name="engine"></a> [engine](#input\_engine_) | Name of the database engine to be used for this DB cluster. Valid Values: aurora-mysql, aurora-postgresql, mysql, postgres. (Note that mysql and postgres are Multi-AZ RDS clusters). | `string` | n/a | yes |
| <a name="engine_version"></a> [engine_version](#input\_engine_version_) | Database engine version. | `string` | n/a | yes |
| <a name="database_name"></a> [database_name](#input\_database_name_) | Data base name | `string` | n/a | yes |
| <a name="deletion_protection"></a> [deletion_protection](#input\_deletion_protection_) | If the DB cluster should have deletion protection enabled. The database can't be deleted when this value is set to true. The default is false. | `bool` | n/a | yes |
| <a name="principal"></a> [principal](#input\_principal_) | If true, it'll be deploy only one node. | `bool` | n/a | yes |
| <a name="engine_mode"></a> [engine_mode](#input\_engine_mode_) | Database engine mode. Valid values: global (only valid for Aurora MySQL 1.21 and earlier), parallelquery, provisioned, serverless. Defaults to: provisioned. See the RDS User Guide for limitations when using serverless. | `string` | n/a | yes |
| <a name="manage_master_user_password"></a> [manage_master_user_password](#input\_manage_master_user_password_) | Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if master_password is provided. | `bool` | n/a | yes |
| <a name="master_password"></a> [master_password](#input\_master_password_) | (Required unless manage_master_user_password is set to true or unless a snapshot_identifier or replication_source_identifier is provided or unless a global_cluster_identifier is provided when the cluster is the "secondary" cluster of a global database) Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file. Please refer to the RDS Naming Constraints. Cannot be set if manage_master_user_password is set to true. | `string` | n/a | no |
| <a name="master_username"></a> [master_username](#input\_master_username_) | Master username for the database | `string` | n/a | yes |
| <a name="backup_retention_period"></a> [backup_retention_period](#input\_backup_retention_period_) | Days to retain backups for. Default 1. | `number` | n/a | yes |
| <a name="skip_final_snapshot"></a> [skip_final_snapshot](#input\_skip_final_snapshot_) | Determines whether a final DB snapshot is created before the DB cluster is deleted. If true is specified, no DB snapshot is created. If false is specified, a DB snapshot is created before the DB cluster is deleted, using the value from final_snapshot_identifier. Default is false. | `bool` | n/a | yes |
| <a name="preferred_backup_window"></a> [preferred_backup_window](#input\_preferred_backup_window_) | Daily time range during which the backups happen | `string` | n/a | yes |
| <a name="storage_encrypted"></a> [storage_encrypted](#input\_storage_encrypted_) | Specifies whether the DB cluster is encrypted | `bool` | n/a | yes |
| <a name="kms_key_id"></a> [kms_key_id](#input\_kms_key_id_) | Amazon Web Services KMS key identifier that is used to encrypt the secret. | `string` | n/a | yes |
| <a name="port"></a> [port](#input\_port_) | Database port | `string` | n/a | yes |
| <a name="service"></a> [service](#input\_service_) | Service name | `string` | n/a | yes |
| <a name="enabled_cloudwatch_logs_exports"></a> [enabled_cloudwatch_logs_exports](#input\_enabled_cloudwatch_logs_exports_) | Set of log types to export to cloudwatch. If omitted, no logs will be exported. The following log types are supported: audit, error, general, slowquery, postgresql (PostgreSQL) | `list(string)` | n/a | yes |
| <a name="copy_tags_to_snapshot"></a> [copy_tags_to_snapshot](#input\_copy_tags_to_snapshot_) | Copy all Cluster tags to snapshots. Default is false. | `bool` | n/a | yes |
| <a name="family"></a> [family](#input\_family_) | The family of the DB cluster parameter group. | `string` | n/a | yes |
| <a name="instance_class"></a> [instance_class](#input\_instance_class_) | Instance class to use. For details on CPU and memory, see Scaling Aurora DB Instances. Aurora uses db.* instance classes/types. Please see AWS Documentation for currently available instance classes and complete details. For Aurora Serverless v2 use db.serverless. | `string` | n/a | yes |
| <a name="publicly_accessible"></a> [publicly_accessible](#input\_publicly_accessible_) | Bool to control if instance is publicly accessible. Default false. See the documentation on Creating DB Instances for more details on controlling this property. | `bool` | n/a | yes |
| <a name="auto_minor_version_upgrade"></a> [auto_minor_version_upgrade](#input\_auto_minor_version_upgrade_) | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. Default true. | `bool` | n/a | yes |
| <a name="performance_insights_enabled"></a> [performance_insights_enabled](#input\_performance_insights_enabled_) | Specifies whether Performance Insights is enabled or not. NOTE: When Performance Insights is configured at the cluster level through aws_rds_cluster, this argument cannot be set to a value that conflicts with the cluster's configuration. | `bool` | n/a | yes |
| <a name="performance_insights_retention_period"></a> [performance_insights_retention_period](#input\_performance_insights_retention_period_) | Specifies the amount of time to retain performance insights data for. Defaults to 7 days if Performance Insights are enabled. Valid values are 7, month * 31 (where month is a number of months from 1-23), and 731. | `number` | n/a | yes |
| <a name="monitoring_interval"></a> [monitoring_interval](#input\_monitoring_interval_) | Interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60. | `number` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="rds_cluster_arn"></a> [rds_cluster_arn](#output\rds_cluster_arn) | ARN of principal cluster RDS |