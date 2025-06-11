###########################################
#Version definition - Terraform - Providers
###########################################

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=5.96.0"
      configuration_aliases = [ aws.principal, aws.secondary ]
    }
  }
}
