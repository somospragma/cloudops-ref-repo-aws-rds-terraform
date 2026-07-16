# PC-IAC-011: Data sources para obtener IDs dinámicos de la VPC, subnets, SG y KMS
# PC-IAC-026: Los IDs se inyectan en locals.tf — NO se hardcodean en terraform.tfvars

##############################################################
# VPC — principal
##############################################################
data "aws_vpc" "principal" {
  provider = aws.principal
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-vpc"]
  }
}

##############################################################
# Subnets de base de datos — principal
# PC-IAC-003: nomenclatura {client}-{project}-{environment}-subnet-database-*
##############################################################
data "aws_subnets" "database_principal" {
  provider = aws.principal
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.principal.id]
  }
  filter {
    name   = "tag:tier"
    values = ["database"]
  }
}

##############################################################
# Security Group RDS — principal
##############################################################
data "aws_security_group" "rds_principal" {
  provider = aws.principal
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-sg-rds-${var.service}"]
  }
}

##############################################################
# KMS key para cifrado RDS — principal
##############################################################
data "aws_kms_alias" "rds_principal" {
  provider = aws.principal
  name     = "alias/${var.client}-${var.project}-${var.environment}-kms-rds-${var.service}"
}

##############################################################
# Caller identity (para referencias a la cuenta actual)
##############################################################
data "aws_caller_identity" "current" {
  provider = aws.principal
}
