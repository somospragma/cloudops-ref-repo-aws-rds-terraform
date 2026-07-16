# PC-IAC-005: El provider se inyecta desde el Root IaC (no se configura en el módulo de referencia)
# Los alias aws.principal y aws.secondary son declarados en versions.tf (configuration_aliases)
# y recibidos del Root al invocar el módulo:
#
#   module "rds" {
#     source = "github.com/somospragma/cloudops-ref-repo-aws-rds-terraform?ref=vX.Y.Z"
#     providers = {
#       aws.principal = aws.principal   # región primaria
#       aws.secondary = aws.principal   # misma región si no hay multi-región
#     }
#   }
