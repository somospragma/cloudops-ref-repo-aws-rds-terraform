# PC-IAC-009: Lógica de inyección y transformación exclusiva en locals.tf
# PC-IAC-026: Flujo obligatorio: terraform.tfvars → variables.tf → locals.tf → main.tf → module
#
# Aquí se inyectan los IDs dinámicos (SG, subnets, KMS) en los objetos de rds_config
# que en terraform.tfvars llegan con valores vacíos ("", [])

locals {
  ##############################################################
  # Prefijo base de gobernanza (PC-IAC-003)
  ##############################################################
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  ##############################################################
  # rds_config transformado — inyecta IDs dinámicos donde estén vacíos
  # Patrón PC-IAC-009: length() > 0 ? valor_declarado : valor_data_source
  ##############################################################
  rds_config_transformed = {
    for cluster_key, cluster in var.rds_config : cluster_key => merge(cluster, {
      cluster_config = [
        for cc in cluster.cluster_config : merge(cc, {
          # Inyectar SG si viene vacío
          vpc_security_group_ids = (
            length(cc.vpc_security_group_ids) > 0
            ? cc.vpc_security_group_ids
            : [data.aws_security_group.rds_principal.id]
          )
          # Inyectar subnets si vienen vacías
          subnet_ids = (
            length(cc.subnet_ids) > 0
            ? cc.subnet_ids
            : data.aws_subnets.database_principal.ids
          )
          # Inyectar KMS key si viene vacía
          kms_key_id = (
            length(cc.kms_key_id) > 0
            ? cc.kms_key_id
            : data.aws_kms_alias.rds_principal.target_key_arn
          )
          # Inyectar KMS de PI en instancias si viene vacío y PI está habilitado
          cluster_instances = [
            for inst in cc.cluster_instances : merge(inst, {
              performance_insights_kms_key_id = (
                inst.performance_insights_enabled && length(inst.performance_insights_kms_key_id) == 0
                ? data.aws_kms_alias.rds_principal.target_key_arn
                : inst.performance_insights_kms_key_id
              )
            })
          ]
        })
      ]
    })
  }
}
