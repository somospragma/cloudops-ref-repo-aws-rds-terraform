terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.1"
      configuration_aliases = [ aws.principal, aws.secondary ]
    }
  }
}
