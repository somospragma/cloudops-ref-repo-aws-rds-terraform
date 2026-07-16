# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2026-07-16

### Corregido
- **BUG CRÍTICO**: `performance_insights_kms_key_id` ya no se pasa cuando `performance_insights_enabled=false`. Antes causaba error `InvalidParameterCombination: To enable Performance Insights, EnablePerformanceInsights must be set to true`.
- **BUG CRÍTICO**: `serverlessv2_scaling_configuration` ahora es un bloque `dynamic` — solo se aplica cuando `serverless_deploy=true`. Antes fallaba si `serverless_deploy=false` porque intentaba crear el bloque con valores null.
- **BUG**: `performance_insights_retention_period` ahora solo se pasa cuando PI está habilitado.
- **BUG**: `monitoring_role_arn` ahora solo se pasa cuando tiene valor (no string vacío).

### Añadido
- **PC-IAC-001**: Archivos faltantes `locals.tf`, `data.tf` y `versions.tf` creados.
- **PC-IAC-002/010**: `rds_config` cambiado de `list(object)` a `map(object)` para estabilidad en `for_each`. Previene destrucción/recreación de recursos al eliminar un elemento intermedio.
- **PC-IAC-003**: Nomenclatura centralizada en `locals.tf` siguiendo patrón `{client}-{project}-{environment}-{type}-{key}-{service}`.
- **PC-IAC-007**: Outputs completos agregados: `principal_cluster_endpoint`, `principal_cluster_reader_endpoint`, `principal_cluster_master_user_secret_arn`, mapas por clave, outputs de instancias y subnet groups. Compatibilidad hacia atrás mantenida.
- **PC-IAC-010**: `lifecycle { prevent_destroy = true }` en `aws_rds_cluster` para proteger contra eliminación accidental.
- **PC-IAC-014**: Bloque `dynamic "serverlessv2_scaling_configuration"` reemplaza bloque estático.
- **Validaciones**: `rds_config` incluye validaciones para engine válido y `cluster_scaling_configuration` requerido cuando `serverless_deploy=true`.

### Cambiado
- `cluster_scaling_configuration` es ahora `optional(object(...), null)` — no rompe configs existentes donde `serverless_deploy=false`.
- `performance_insights_kms_key_id` movido al nivel de `cluster_instances` (donde realmente se usa).
- Lógica de aplanado de configuraciones movida a `locals.tf` (PC-IAC-009).

### Soporte de modos de despliegue
Ambos modos son soportados en la misma variable `rds_config`:

**Serverless v2 (`serverless_deploy=true`):**
```hcl
rds_config = {
  "mi-cluster" = {
    serverless_deploy = true
    cluster_config = [{
      engine_mode  = "provisioned"
      cluster_scaling_configuration = { max_capacity = 2, min_capacity = 0.5 }
      cluster_instances = [{ instance_class = "db.serverless", performance_insights_enabled = true }]
    }]
  }
}
```

**Instancia provisionada (`serverless_deploy=false`):**
```hcl
rds_config = {
  "mi-cluster" = {
    serverless_deploy = false
    cluster_config = [{
      engine_mode  = "provisioned"
      cluster_scaling_configuration = null  # o simplemente no declarar
      cluster_instances = [{ instance_class = "db.t3.medium", performance_insights_enabled = false }]
    }]
  }
}
```

## [1.0.0] - 2024-01-01

### Añadido
- Versión inicial del módulo RDS Aurora con soporte para clusters global y single-region.
- Soporte para Aurora MySQL y Aurora PostgreSQL.
- Parameter groups para cluster e instancias.
- Subnet groups automáticos.
- Integración con Secrets Manager para gestión de contraseña maestra.
