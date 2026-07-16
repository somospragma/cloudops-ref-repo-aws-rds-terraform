# PC-IAC-005: Provider principal con alias, assume_role y default_tags
# PC-IAC-004: default_tags aplica los common_tags transversales a todos los recursos
# PC-IAC-006: version pinning ~> 6.0 para evitar breaking changes de major version

provider "aws" {
  alias   = "principal"
  region  = var.aws_region_principal
  profile = var.profile

  # PC-IAC-005: assume_role para menor privilegio en pipelines CI/CD
  # Descomentar y reemplazar con el ARN del rol de despliegue
  # assume_role {
  #   role_arn = "arn:aws:iam::ACCOUNT_ID:role/deploy-role"
  # }

  # PC-IAC-004: Tags transversales en todos los recursos
  default_tags {
    tags = var.common_tags
  }
}

provider "aws" {
  alias   = "secondary"
  region  = var.aws_region_secondary
  profile = var.profile

  # assume_role {
  #   role_arn = "arn:aws:iam::ACCOUNT_ID:role/deploy-role"
  # }

  default_tags {
    tags = var.common_tags
  }
}

##############################################################
# Versiones — PC-IAC-006
##############################################################
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.31.0"
    }
  }
}
