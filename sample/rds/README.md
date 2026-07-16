# Sample — cloudops-ref-repo-aws-rds-terraform

Ejemplo funcional de consumo del módulo RDS Aurora. Soporta **dos modos**:
- **Serverless v2** (`serverless_deploy=true`, `instance_class="db.serverless"`)
- **Instancia provisionada** (`serverless_deploy=false`, `instance_class="db.t3.medium"` etc.)

## Patrón de transformación (PC-IAC-026)

```
terraform.tfvars  →  variables.tf  →  locals.tf  →  main.tf  →  module "rds"
   (config base)      (tipos)         (IDs dinám.)   (invoca)
```

Los IDs de VPC, subnets, SG y KMS se declaran **vacíos** en `terraform.tfvars`
y son inyectados automáticamente en `locals.tf` desde data sources usando la
nomenclatura estándar `{client}-{project}-{environment}-*`.

## Pre-requisitos

Los siguientes recursos deben existir **antes** de ejecutar este sample:

| Recurso | Tag Name esperado |
|---------|-------------------|
| VPC | `{client}-{project}-{env}-vpc` |
| Subnets de BD | tag `tier = database` en la VPC |
| Security Group | `{client}-{project}-{env}-sg-rds-{service}` |
| KMS alias | `alias/{client}-{project}-{env}-kms-rds-{service}` |

## Ejecución

```bash
# 1. Copiar el archivo de variables de ejemplo
cp terraform.tfvars.sample terraform.tfvars

# 2. Editar terraform.tfvars con tus valores (profile, región, client, project, etc.)
vi terraform.tfvars

# 3. Inicializar
terraform init

# 4. Planear
terraform plan

# 5. Aplicar
terraform apply
```

## Modos de despliegue

### Serverless v2

```hcl
rds_config = {
  "mi-cluster" = {
    serverless_deploy = true
    cluster_config = [{
      cluster_scaling_configuration = { max_capacity = 2, min_capacity = 0.5 }
      cluster_instances = [{ instance_class = "db.serverless" }]
    }]
  }
}
```

### Instancia provisionada

```hcl
rds_config = {
  "mi-cluster" = {
    serverless_deploy = false
    cluster_config = [{
      cluster_scaling_configuration = null  # no requerido
      cluster_instances = [{
        instance_class               = "db.t3.medium"
        performance_insights_enabled = false  # db.t3.medium no soporta PI
      }]
    }]
  }
}
```

> **Nota:** `db.t3.micro` y `db.t3.medium` **no soportan Performance Insights**.
> Poner `performance_insights_enabled = false` para esas clases de instancia.
