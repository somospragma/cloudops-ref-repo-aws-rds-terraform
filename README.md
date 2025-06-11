# **Módulo Terraform: cloudops-ref-repo-aws-rds-terraform**

## Descripción:

Este módulo facilita la creación y gestión de recursos de Amazon Relational Database Service (RDS) en AWS con las mejores prácticas de seguridad, nomenclatura y configuración según los estándares.

Requiere realizar la configuración prevía de los siguientes recursos:
- vpc_security_group_ids: Ids of security groups.
- subnet_ids: Ids of subnets.
- kms_key_id: Id of KMS.

Consulta CHANGELOG.md para la lista de cambios de cada versión. Se recomienda fijar la versión exacta del módulo en el código para la infraestructura permanezca estable y se actualicen las versiones de manera sistemática para evitar posibles problemas por incompatibilidad de versiones.

## Características:
- Creación de Aurora Global con clusters en diferentes regiones
- Creación de Aurora Serverless V2 Global con clusters en diferentes regiones
- Creación de Aurora Cluster con un writer y múltiples readers en una misma región
- Creación de Aurora Serverless V2 Cluster con un writer y múltiples readers en una misma región
- Cifrado mediante AWS KMS (clave predeterminada o personalizada)
- Despliegue en múltiples subredes para alta disponibilidad
- Despliegue en múltiples regiones para recuperación de desastres
- Uso de grupos de seguridad para control de acceso
- Etiquetado consistente según estándares organizacionales
- Integración con AWS Secrets Manager para gestión automática y rotación de la contraseña del usuario administrador
- Habilitación de Performance Insights para obtener datos de rendimiento que mejoran la observabilidad
- Habilitación de Enhance Monitoring para obtener datos de rendimiento que mejoran la observabilidad 

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
- Los archivos `CHANGELOG.md` y `README.md` contienen información de uso, documentación y cambios.
- La carpeta `sample/` contiene un ejemplo de implementación del módulo.

## Provider Configuration

Este módulo requiere la configuración de un provider específico para el proyecto. Debe configurarse de la siguiente manera:

```hcl
sample/rds/providers.tf
provider "aws" {
  alias = "principal"
  # ... otras configuraciones del provider
}

provider "aws" {
  alias = "secundario"
  # ... otras configuraciones del provider
}

sample/rds/main.tf
module "rds" {
  source = ""
  providers = {
    aws.project = aws.principal
    aws.project = aws.secundario
  }
  # ... resto de la configuración
}
```

## Uso del Módulo:

```hcl
module "rds-aurora" {
  source = "../../"
  
  providers = {
    aws.principal = aws.principal          #Write manually alias (the same alias name configured in providers.tf)
  }

  # Common configuration
  environment = "dev"
  client      = "pragma"
  project     = "idp"
  service     = "rds"

  master_password = "xxxxxx"

  # RDS configuration
  rds_config = [
    {
      create_global_cluster = "xxxxxx"
      cluster_application   = "xxxxxx"                      
      engine                = "xxxxxx"                          
      engine_version        = "xxxxxx"          
      database_name         = "xxxxxx"                 
      deletion_protection   = "xxxxxx"
      storage_encrypted     = "xxxxxx"
      serverless_deploy     = "xxxxxx"                         
      cluster_config = [
        {
          principal                       = "xxxxxx"                   
          region                          = "xxxxxx"             
          engine_mode                     = "xxxxxx"         
          manage_master_user_password     = "xxxxxx"                  
          master_password                 = ""           
          master_username                 = "xxxxxx"                
          vpc_security_group_ids          = ["xxxxxx"]
          subnet_ids                      = ["xxxxxx", "xxxxxx"]       
          backup_retention_period         = "xxxxxx"                       
          skip_final_snapshot             = "xxxxxx"                  
          preferred_backup_window         = "xxxxxx"                           
          kms_key_id                      = "xxxxxx"
          port                            = "xxxxxx"                  
          service                         = "xxxxxx"               
          enabled_cloudwatch_logs_exports = "xxxxxx"                    
          copy_tags_to_snapshot           = "xxxxxx"
          cluster_parameter = {
            family      = "xxxxxx"                                  
            description = "xxxxxx"
            parameters  = []
          }
          cluster_scaling_configuration = {
            max_capacity             = "xxxxxx"
            min_capacity             = "xxxxxx"
            seconds_until_auto_pause = "xxxxxx"
          }
          instance_parameter = {
            family      = "xxxxxx"                                 
            parameters  = []
          }
          cluster_instances = [
            {
              instance_class                        = "xxxxxx"
              publicly_accessible                   = "xxxxxx"                
              auto_minor_version_upgrade            = "xxxxxx"                 
              performance_insights_enabled          = "xxxxxx"                
              performance_insights_retention_period = "xxxxxx"                   
              monitoring_interval                   = "xxxxxx"
              monitoring_role_arn                   = "xxxxxx"                    
            }
          ]
        }
      ]
    }
  ]
  depends_on = [module.kms, module.security_groups]
}
```

## Convenciones de nomenclatura

El módulo sigue un estándar de nomenclatura para los recursos:

```hcl
#Global database
{client}-{project}-{environment}-{cluster_application}-glb-{service}

#Cluster
{client}-{project}-{environment}-cluster-{cluster_application}-{region}-{index}-{service}

#Instancia
{client}-{project}-{environment}-rds-instance-{cluster_application}-{service}-{index}

#Subnet group
{client}-{project}-{environment}-sn-grp-{cluster_application}-{region}-{index}-{service}

#Parameter group
{client}-{project}-{environment}-instance-parameter-{cluster_application}-{service}
```

Por ejemplo:
- pragma-idp-dev-serverless-sample-glb-default
- pragma-idp-dev-cluster-serverless-sample-us-east-1-0-default
- pragma-idp-dev-rds-instance-serverless-sample-default-1
- pragma-idp-dev-sn-grp-serverless-sample-us-east-1-0-default

## Etiquetas

El módulo maneja el etiquetado de la siguiente manera:

- **Etiquetas obligatorias**: Se aplican a través del provider AWS usando default_tags en la configuración del provider.

```hcl
provider "aws" {
  default_tags {
    tags = {
      environment = "dev"
      project-name = "idp"
      cost-center = "cloud-ops"
      owner = "cloudops"
      area = "infrastructure"
      provisioned = "terraform"
      datatype = "operational"
    }
  }
}
```

- **Etiqueta Name**: Se genera automáticamente siguiendo el estándar de nomenclatura para cada recurso.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.96.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.project"></a> [aws.project](#provider\_aws) | >= 5.96.0 |

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
| <a name="client"></a> [client](#input\client) | Identificador del cliente | `string` | n/a | yes |
| <a name="project"></a> [project](#input\project) | Nombre del proyecto asociado a la RDS | `string` | n/a | yes |
| <a name="environment"></a> [environment](#input\environment) | Entorno de despliegue (dev, qa, pdn) | `string` | n/a | yes |
| <a name="service"></a> [service](#input\service) | Nombre del servicio | `string` | n/a | yes |
| <a name="master_password"></a> [master_password](#input\master_password) | Clave del usuario administrador de la RDS | `string` | n/a | yes |
| <a name="rds_config"></a> [rds_config](#input\rds_config) | Configuración de la RDS | `map(object)` | n/a | yes |

Variables dentro del objeto rds_config

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="create_global_cluster"></a> [create_global_cluster](#input\_create_global_cluster_) | Si el valor es true, se crea un cluster global. | `bool` | n/a | yes |
| <a name="cluster_application"></a> [cluster_application](#input\_cluster_application_) | Nombre del cluster. | `string` | n/a | yes |
| <a name="engine"></a> [engine](#input\_engine_) | Nombre del motor de base de datos usado para lanzar el cluster. Valores válidos aurora-mysql, aurora-postgresql, mysql, postgres. | `string` | n/a | yes |
| <a name="engine_version"></a> [engine_version](#input\_engine_version_) | Versión del motor de base de datos. | `string` | n/a | yes |
| <a name="database_name"></a> [database_name](#input\_database_name_) | Nombre de la base de datos | `string` | n/a | yes |
| <a name="deletion_protection"></a> [deletion_protection](#input\_deletion_protection_) | Indica si se habilita la protección de borrado de la base de datos. Si el valor es true, la base de datos no se puede borrar. El valor por defecto es false. | `bool` | n/a | yes |
| <a name="principal"></a> [principal](#input\_principal_) | Indica si este cluster es el primario | `bool` | n/a | yes |
| <a name="engine_mode"></a> [engine_mode](#input\_engine_mode_) | Modo del motor de base de datos. Valores válidos: provisioned o serverless. El modo serverless solo aplica para Aurora Serverless V1. Aurora Serverless V2 usa el modo provisioned. | `string` | n/a | yes |
| <a name="manage_master_user_password"></a> [manage_master_user_password](#input\_manage_master_user_password_) | Indica si la contraseña del usuario administrador se gestiona automáticamente como secreto en el servicio AWS Secrets Manager. Se debe configurar en false cuando se configura la clave en la propiedad **master_password** o cuando se crea un cluster global. | `bool` | n/a | yes |
| <a name="master_password"></a> [master_password](#input\_master_password_) | Contraseña del usuario administrador de la base de datos. Tener cuidado con su manejo ya que se podría almacenar en los logs o en el archivo de estado de terraform. No se debe configurar si la propiedad **manage_master_user_password** está configurada con el valor true. Se recomienda almacenar el valor en AWS Secrets Manager o Parameter Store y crear un data para obtener su valor desde terraform. | `string` | n/a | no |
| <a name="master_username"></a> [master_username](#input\_master_username_) | Nombre del usuario administrador de la base de datos. | `string` | n/a | yes |
| <a name="backup_retention_period"></a> [backup_retention_period](#input\_backup_retention_period_) | Período de retención (en días) de los backups. Default 1. | `number` | n/a | yes |
| <a name="skip_final_snapshot"></a> [skip_final_snapshot](#input\_skip_final_snapshot_) | Determina si se crea un snapshot final cuando se elimina la base de datos. Si el valor es true no se genera el snapshot, si es false, se crea el snapshot antes de realizar la eliminación. Default is false. | `bool` | n/a | yes |
| <a name="preferred_backup_window"></a> [preferred_backup_window](#input\_preferred_backup_window_) | Hora del día  durante la cual se generan los backups. | `string` | n/a | yes |
| <a name="storage_encrypted"></a> [storage_encrypted](#input\_storage_encrypted_) | Indica si se habilita el cifrado del cluster. | `bool` | n/a | yes |
| <a name="kms_key_id"></a> [kms_key_id](#input\_kms_key_id_) | Id de la llave KMS usada para cifrar el cluster. | `string` | n/a | yes |
| <a name="port"></a> [port](#input\_port_) | Puerto del servicio de base de datos | `string` | n/a | yes |
| <a name="service"></a> [service](#input\_service_) | Nombre del servicio, por ejemplo: rds | `string` | n/a | yes |
| <a name="enabled_cloudwatch_logs_exports"></a> [enabled_cloudwatch_logs_exports](#input\_enabled_cloudwatch_logs_exports_) | Habilita el envío de logs a CloudWatch. Valores válidos: **Aurora MySQL** (audit - error - general - instance - slowquery - iam-db-auth-error) **Aurora PostgreSQL** (instance - postgresql - iam-db-auth-error) **RDS for MySQL** (error - general - slowquery - iam-db-auth-error) **RDS for PostgreSQL** (postgresql - upgrade - iam-db-auth-error) | `list(string)` | n/a | yes |
| <a name="copy_tags_to_snapshot"></a> [copy_tags_to_snapshot](#input\_copy_tags_to_snapshot_) | Indica si se deben copiar todos los tags del cluster a los snapshots. Default is false. | `bool` | n/a | yes |
| <a name="family"></a> [family](#input\_family_) | Familia del grupo de parámetros del cluster. Ejemplos: Aurora MySQL (aurora-mysql5.7, aurora-mysql8.0) Aurora PostgreSQL (aurora-postgresql14) RDS for MySQL (mysql8.0) RDS for PostgreSQL (postgres13) | `string` | n/a | yes |
| <a name="instance_class"></a> [instance_class](#input\_instance_class_) | Tipo de instancia. Ejemplo: db.t3.medium, db.serverless, db.r5.large. Cuando se active la opción create_global_cluster, se deben utilizar instancias serverless o instancias optimizadas para aplicaciones con uso intensivo de memoria, por ejemplo instancias de tipo db.r5.* | `string` | n/a | yes |
| <a name="publicly_accessible"></a> [publicly_accessible](#input\_publicly_accessible_) | Indica si se expone públicamente la instancia. Default false. | `bool` | n/a | yes |
| <a name="auto_minor_version_upgrade"></a> [auto_minor_version_upgrade](#input\_auto_minor_version_upgrade_) | Indica que se aplican las actualizaciones menores del motor de base de datos automáticamente durante la ventana de mantenimiento. Default true. | `bool` | n/a | yes |
| <a name="performance_insights_enabled"></a> [performance_insights_enabled](#input\_performance_insights_enabled_) | Indica si se habilita Performance Insights. | `bool` | n/a | yes |
| <a name="performance_insights_retention_period"></a> [performance_insights_retention_period](#input\_performance_insights_retention_period_) | Indica el período de retención de los datos de Performance Insights. Defaults 7 días. Valores válidos 7, mes * 31 (donde mes es un número entre 1-23) y 731. | `number` | n/a | yes |
| <a name="monitoring_interval"></a> [monitoring_interval](#input\_monitoring_interval_) | Intervalo, en segundos, donde recolectan las métricas de Enhanced Monitoring para la instancia. Para deshabilitar esta opción configurar el valor 0. Default 0. Valores válidos: 0, 1, 5, 10, 15, 30, 60. | `number` | n/a | yes |
| <a name="monitoring_role_arn"></a> [monitoring_role_arn](#input\_monitoring_role_arn_) | ARN del rol requerido para habilitar Enhance Monitoring | `number` | n/a | yes |
| <a name="max_capacity"></a> [max_capacity](#input\_max_capacity_) | Número máximo de unidades de capacidad (ACUs) de la instancia en el cluster de Aurora Serverless V2. Valores válidos: Aurora MySQL (1, 2, 4, 8, 16, 32, 64, 128, 256). Aurora PostgreSQL (2, 4, 8, 16, 32, 64, 192, and 384). | `string` | n/a | yes |
| <a name="min_capacity"></a> [min_capacity](#input\_min_capacity_) | Número mínimo de unidades de capacidad (ACUs) de la instancia en el cluster de Aurora Serverless V2. Valores válidos: Aurora MySQL (1, 2, 4, 8, 16, 32, 64, 128, 256). Aurora PostgreSQL (2, 4, 8, 16, 32, 64, 192, and 384). | `string` | n/a | yes |
| <a name="seconds_until_auto_pause"></a> [seconds_until_auto_pause](#input\_seconds_until_auto_pause_) | Indica el número de segundos que una instancia puede permanecer ociosa antes de que se intente detener automáticamente. Valores válidos entre 300 y 86400  | `number` | n/a | yes |


### Estructura de `rds_config`

```hcl
variable "rds_config" {
  type = list(object({
    create_global_cluster = bool       # Controla la creación del cluster global.
    cluster_application   = string     # Nombre del cluster. 
    engine                = string     # Nombre del motor de base de datos usado para lanzar el cluster.
    engine_version        = string     # Versión del motor de base de datos. 
    database_name         = string     # Nombre de la base de datos.
    deletion_protection   = bool       # Indica si se habilita la protección de borrado de la base de datos.
    storage_encrypted     = bool       # Indica si se habilita el cifrado para el almacenamiento.
    serverless_deploy     = bool       # Controla la configuración para el escalamiento de Aurora Serverless V2.
    
    # Configuración del cluster primario y secundario.
    cluster_config = list(object({                           
      principal                       = bool                 # Indica si este cluster es el primario
      region                          = string               # Región usada para configurar el cluster
      engine_mode                     = string               # Modo del motor de base de datos. 
      manage_master_user_password     = bool                 # Gestionar automáticamente la contraseña del usuario administrador en AWS Secrets Manager.
      master_password                 = optional(string)     # Contraseña del usuario administrador de la base de datos.
      master_username                 = string               # Nombre de usuario del administrador de la base de datos
      vpc_security_group_ids          = list(string)         # Ids de los grupos de seguridad configurados para la instancia RDS.
      subnet_ids                      = list(string)         # Ids de las subredes donde se despliegan las instancias RDS.
      backup_retention_period         = number               # Período de retención de los backups automáticos.
      skip_final_snapshot             = bool                 # Indida si se genera un backup final antes de eliminar la base de datos.
      preferred_backup_window         = string               # Ventana de mantenimiento durante la cual se genera el backup.
      kms_key_id                      = string               # Id de la llave KMS usada para cifrar el cluster.
      port                            = string               # Puerto donde se expone el servicio de base de datos.
      service                         = string               # Nombre del servicio
      enabled_cloudwatch_logs_exports = list(string)         # Habilita el envío de logs a CloudWatch
      copy_tags_to_snapshot           = bool                 # Copia todos los tags del cluster al snapshot
      
      # Parámetros de configuración del cluster
      cluster_parameter = object({                           
        family      = string                                 # Familia del grupo de parámetros del cluster.
        description = string
        parameters = list(object({
          name         = string
          value        = string
          apply_method = string
        }))
      })

      # Configuración de escalamiento del cluster Aurora Serverless V2
      cluster_scaling_configuration = object({               
        max_capacity             = string                    # Número máximo de unidades de capacidad (ACUs) de la instancia en el cluster de Aurora Serverless V2
        min_capacity             = string                    # Número mínimo de unidades de capacidad (ACUs) de la instancia en el cluster de Aurora Serverless V2
        seconds_until_auto_pause = string                    # Indica el número de segundos que una instancia puede permanecer ociosa antes de que se intente detener automáticamente
      })

      # Parámetros de configuración del cluster
      instance_parameter = object({                          
        family = string
        parameters = list(object({
          name         = string
          value        = string
          apply_method = string
        }))
      })

      # Configuración instancias del cluster
      cluster_instances = list(object({   
        record_id                             = string       # Identificador único del registro. Por ejemplo: instancia_1, instancia_2, etc.                   
        instance_class                        = string       # Tipo de instancia. Ejemplo: db.t3.medium, db.serverless, db.r5.large.
        publicly_accessible                   = bool         # Indica si se expone públicamente la instancia
        auto_minor_version_upgrade            = bool         # Aplicar actualizaciones de versiones menores automáticamente
        performance_insights_enabled          = bool         # Activar Performance Insights
        performance_insights_retention_period = number       # Período de retención de las métricas en Performance Insights
        monitoring_interval                   = number       # Permite habilitar el Enhance Monitoring. 
        monitoring_role_arn                   = string       # ARN del rol requerido para habilitar Enhance Monitoring
      }))
    }))
  }))
}
```

## Outputs

| Name | Description |
|------|-------------|
| <a name="rds_cluster_arn"></a> [rds_cluster_arn](#output\rds_cluster_arn) | ARN of principal cluster RDS |


## Escenarios de uso comunes

### 1. Cluster regional con instancia serverless

Cluster con una instancia serverless (writer y reader) y gestión automática de la contraseña del usuario administrador en AWS Secrets Manager.

```hcl
master_password = ""
rds_config = [
    {
      create_global_cluster = false
      cluster_application   = "serverless-sample"                       
      engine                = "aurora-postgresql"                          
      engine_version        = "16.6"          
      database_name         = "sample"                 
      deletion_protection   = true
      storage_encrypted     = true
      serverless_deploy     = true                         
      cluster_config = [
        {
          principal                       = true                   
          region                          = "us-east-1"             
          engine_mode                     = "provisioned"          
          manage_master_user_password     = true       
          master_username                 = "master"               
          vpc_security_group_ids          = ["sg-0b2d8a661edfca138"]
          subnet_ids                      = ["subnet-0ddb9d265401e8cfd","subnet-04f94e308054161eb"]       
          backup_retention_period         = 7                      
          skip_final_snapshot             = true                  
          preferred_backup_window         = "00:00-00:30"                           
          kms_key_id                      = "arn:aws:kms:us-east-1:008971642453:key/2a9dd3ab-d630-487a-b8ce-65c13dbf180f"
          port                            = "3306"                  
          service                         = "rds"               
          enabled_cloudwatch_logs_exports = ["postgresql","iam-db-auth-error"]                    
          copy_tags_to_snapshot           = true
          cluster_parameter = {
            family      = "aurora-postgresql16"                                  
            description = "Aurora PostgreSQL 16.6 default cluster parameters"
            parameters  = []
          }
          cluster_scaling_configuration = {
            max_capacity             = 1
            min_capacity             = 0
            seconds_until_auto_pause = 86400
          }
          instance_parameter = {
            family      = "aurora-postgresql16"                                 
            parameters  = []
          }
          cluster_instances = [
            {
              record_id                             = "instancia_1"
              instance_class                        = "db.serverless"
              publicly_accessible                   = false               
              auto_minor_version_upgrade            = true                 
              performance_insights_enabled          = false               
              performance_insights_retention_period = 7                   
              monitoring_interval                   = 0
              monitoring_role_arn                   = ""                    
            }
          ]
        }
      ]
    }
  ]
```

### 2. Cluster regional con instancia db.t3.medium

Cluster con una instancia db.t3.medium (writer y reader) y gestión automática de la contraseña del usuario administrador en AWS Secrets Manager.

```hcl
master_password = ""
rds_config = [
    {
      create_global_cluster = false
      cluster_application   = "aurora-sample"                       
      engine                = "aurora-postgresql"                          
      engine_version        = "16.6"          
      database_name         = "sample"                 
      deletion_protection   = true
      storage_encrypted     = true
      serverless_deploy     = false                         
      cluster_config = [
        {
          principal                       = true                   
          region                          = "us-east-1"             
          engine_mode                     = "provisioned"          
          manage_master_user_password     = true       
          master_username                 = "master"               
          vpc_security_group_ids          = ["sg-0b2d8a661edfca138"]
          subnet_ids                      = ["subnet-0ddb9d265401e8cfd","subnet-04f94e308054161eb"]       
          backup_retention_period         = 7                      
          skip_final_snapshot             = true                  
          preferred_backup_window         = "00:00-00:30"                           
          kms_key_id                      = "arn:aws:kms:us-east-1:008971642453:key/2a9dd3ab-d630-487a-b8ce-65c13dbf180f"
          port                            = "3306"                  
          service                         = "rds"               
          enabled_cloudwatch_logs_exports = ["postgresql","iam-db-auth-error"]                    
          copy_tags_to_snapshot           = true
          cluster_parameter = {
            family      = "aurora-postgresql16"                                  
            description = "Aurora PostgreSQL 16.6 default cluster parameters"
            parameters  = []
          }
          cluster_scaling_configuration = {
            max_capacity             = 1
            min_capacity             = 0
            seconds_until_auto_pause = 86400
          }
          instance_parameter = {
            family      = "aurora-postgresql16"                                 
            parameters  = []
          }
          cluster_instances = [
            {
              record_id                             = "instancia_1"
              instance_class                        = "db.t3.medium"
              publicly_accessible                   = false               
              auto_minor_version_upgrade            = true                 
              performance_insights_enabled          = false               
              performance_insights_retention_period = 7                   
              monitoring_interval                   = 0
              monitoring_role_arn                   = ""                    
            }
          ]
        }
      ]
    }
  ]
```

### 3. Cluster regional con dos instancias serverless writer y reader 

Cluster con dos instancia serverless (writer y reader) y gestión automática de la contraseña del usuario administrador en AWS Secrets Manager.

```hcl
master_password = ""
rds_config = [
    {
      create_global_cluster = false
      cluster_application   = "serverless-sample"                       
      engine                = "aurora-postgresql"                          
      engine_version        = "16.6"          
      database_name         = "sample"                 
      deletion_protection   = true
      storage_encrypted     = true
      serverless_deploy     = true                         
      cluster_config = [
        {
          principal                       = true                   
          region                          = "us-east-1"             
          engine_mode                     = "provisioned"          
          manage_master_user_password     = true       
          master_username                 = "master"               
          vpc_security_group_ids          = ["sg-0b2d8a661edfca138"]
          subnet_ids                      = ["subnet-0ddb9d265401e8cfd","subnet-04f94e308054161eb"]       
          backup_retention_period         = 7                      
          skip_final_snapshot             = true                  
          preferred_backup_window         = "00:00-00:30"                           
          kms_key_id                      = "arn:aws:kms:us-east-1:008971642453:key/2a9dd3ab-d630-487a-b8ce-65c13dbf180f"
          port                            = "3306"                  
          service                         = "rds"               
          enabled_cloudwatch_logs_exports = ["postgresql","iam-db-auth-error"]                    
          copy_tags_to_snapshot           = true
          cluster_parameter = {
            family      = "aurora-postgresql16"                                  
            description = "Aurora PostgreSQL 16.6 default cluster parameters"
            parameters  = []
          }
          cluster_scaling_configuration = {
            max_capacity             = 1
            min_capacity             = 0
            seconds_until_auto_pause = 86400
          }
          instance_parameter = {
            family      = "aurora-postgresql16"                                 
            parameters  = []
          }
          cluster_instances = [
            {
              record_id                             = "instancia_1"
              instance_class                        = "db.serverless"
              publicly_accessible                   = false               
              auto_minor_version_upgrade            = true                 
              performance_insights_enabled          = false               
              performance_insights_retention_period = 7                   
              monitoring_interval                   = 0
              monitoring_role_arn                   = ""                    
            },
            {
              record_id                             = "instancia_2"
              instance_class                        = "db.serverless"
              publicly_accessible                   = false               
              auto_minor_version_upgrade            = true                 
              performance_insights_enabled          = false               
              performance_insights_retention_period = 7                   
              monitoring_interval                   = 0
              monitoring_role_arn                   = ""                    
            }
          ]
        }
      ]
    }
  ]
```

### 4. Aurora global con un cluster regional serverless principal

Aurora global con un cluster, una instancia serverless (writer y reader) y gestión manual de la contraseña del usuario administrador en AWS Secrets Manager.

```hcl
master_password = jsondecode(data.aws_secretsmanager_secret_version.current_p.secret_string)["password"]
rds_config = [
    {
      create_global_cluster = true
      cluster_application   = "serverless-sample"                       
      engine                = "aurora-postgresql"                          
      engine_version        = "16.6"          
      database_name         = "sample"                 
      deletion_protection   = true
      storage_encrypted     = true
      serverless_deploy     = true                         
      cluster_config = [
        {
          principal                       = true                   
          region                          = "us-east-1"             
          engine_mode                     = "provisioned"          
          manage_master_user_password     = false       
          master_username                 = "master"               
          vpc_security_group_ids          = ["sg-0b2d8a661edfca138"]
          subnet_ids                      = ["subnet-0ddb9d265401e8cfd","subnet-04f94e308054161eb"]       
          backup_retention_period         = 7                      
          skip_final_snapshot             = true                  
          preferred_backup_window         = "00:00-00:30"                           
          kms_key_id                      = "arn:aws:kms:us-east-1:008971642453:key/2a9dd3ab-d630-487a-b8ce-65c13dbf180f"
          port                            = "3306"                  
          service                         = "rds"               
          enabled_cloudwatch_logs_exports = ["postgresql","iam-db-auth-error"]                    
          copy_tags_to_snapshot           = true
          cluster_parameter = {
            family      = "aurora-postgresql16"                                  
            description = "Aurora PostgreSQL 16.6 default cluster parameters"
            parameters  = []
          }
          cluster_scaling_configuration = {
            max_capacity             = 1
            min_capacity             = 0
            seconds_until_auto_pause = 86400
          }
          instance_parameter = {
            family      = "aurora-postgresql16"                                 
            parameters  = []
          }
          cluster_instances = [
            {
              record_id                             = "instancia_1"
              instance_class                        = "db.serverless"
              publicly_accessible                   = false               
              auto_minor_version_upgrade            = true                 
              performance_insights_enabled          = false               
              performance_insights_retention_period = 7                   
              monitoring_interval                   = 0
              monitoring_role_arn                   = ""                    
            }
          ]
        }
      ]
    }
  ]
```

### 5. Aurora global con dos cluster regional serverless principal y secundario

Aurora global con dos clusters cada uno con un instancia serverless y gestión manual de la contraseña del usuario administrador en AWS Secrets Manager.

```hcl
master_password = jsondecode(data.aws_secretsmanager_secret_version.current_p.secret_string)["password"]
rds_config = [
    {
      create_global_cluster = true
      cluster_application   = "serverless-sample"                       
      engine                = "aurora-postgresql"                          
      engine_version        = "16.6"          
      database_name         = "sample"                 
      deletion_protection   = true
      storage_encrypted     = true
      serverless_deploy     = true                         
      cluster_config = [
        {
          principal                       = true                   
          region                          = "us-east-1"             
          engine_mode                     = "provisioned"          
          manage_master_user_password     = false       
          master_username                 = "master"               
          vpc_security_group_ids          = ["sg-0b2d8a661edfca138"]
          subnet_ids                      = ["subnet-0ddb9d265401e8cfd","subnet-04f94e308054161eb"]       
          backup_retention_period         = 7                      
          skip_final_snapshot             = true                  
          preferred_backup_window         = "00:00-00:30"                           
          kms_key_id                      = "arn:aws:kms:us-east-1:008971642453:key/2a9dd3ab-d630-487a-b8ce-65c13dbf180f"
          port                            = "3306"                  
          service                         = "rds"               
          enabled_cloudwatch_logs_exports = ["postgresql","iam-db-auth-error"]                    
          copy_tags_to_snapshot           = true
          cluster_parameter = {
            family      = "aurora-postgresql16"                                  
            description = "Aurora PostgreSQL 16.6 default cluster parameters"
            parameters  = []
          }
          cluster_scaling_configuration = {
            max_capacity             = 1
            min_capacity             = 0
            seconds_until_auto_pause = 86400
          }
          instance_parameter = {
            family      = "aurora-postgresql16"                                 
            parameters  = []
          }
          cluster_instances = [
            {
              record_id                             = "instancia_1"
              instance_class                        = "db.serverless"
              publicly_accessible                   = false               
              auto_minor_version_upgrade            = true                 
              performance_insights_enabled          = false               
              performance_insights_retention_period = 7                   
              monitoring_interval                   = 0
              monitoring_role_arn                   = ""                    
            }
          ]
        },
        {
          principal                       = false                   
          region                          = "us-west-2"             
          engine_mode                     = "provisioned"          
          manage_master_user_password     = false       
          master_username                 = "master"               
          vpc_security_group_ids          = ["sg-08d5d0a1ee893dae3"]
          subnet_ids                      = ["subnet-0679b40ca84b03deb","subnet-073bb76cc314145d3"]       
          backup_retention_period         = 7                      
          skip_final_snapshot             = true                  
          preferred_backup_window         = "00:00-00:30"                           
          kms_key_id                      = "arn:aws:kms:us-west-2:008971642453:key/11842d1a-81ff-4ee2-9598-94ac02d0615f"
          port                            = "3306"                  
          service                         = "rds"               
          enabled_cloudwatch_logs_exports = ["postgresql","iam-db-auth-error"]                    
          copy_tags_to_snapshot           = true
          cluster_parameter = {
            family      = "aurora-postgresql16"                                  
            description = "Aurora PostgreSQL 16.6 default cluster parameters"
            parameters  = []
          }
          cluster_scaling_configuration = {
            max_capacity             = 1
            min_capacity             = 0
            seconds_until_auto_pause = 86400
          }
          instance_parameter = {
            family      = "aurora-postgresql16"                                 
            parameters  = []
          }
          cluster_instances = [
            {
              record_id                             = "instancia_1"
              instance_class                        = "db.serverless"
              publicly_accessible                   = false               
              auto_minor_version_upgrade            = true                 
              performance_insights_enabled          = false               
              performance_insights_retention_period = 7                   
              monitoring_interval                   = 0
              monitoring_role_arn                   = ""                    
            }
          ]
        }
      ]
    }
  ]
```

## Seguridad & Cumplimiento
 
Consulta a continuación la fecha y los resultados de nuestro escaneo de seguridad y cumplimiento.

<!-- BEGIN_BENCHMARK_TABLE -->
| Benchmark | Date | Version | Description | 
| --------- | ---- | ------- | ----------- | 
| ![checkov](https://img.shields.io/badge/checkov-passed-green) | 2025-05-15 | 3.2.416 | Escaneo profundo del plan de Terraform en busca de problemas de seguridad y cumplimiento |
<!-- END_BENCHMARK_TABLE -->