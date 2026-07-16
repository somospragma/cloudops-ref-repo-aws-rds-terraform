# PC-IAC-005: Alias consumidores aws.principal y aws.secondary para clusters multi-región
# PC-IAC-006: Pinning de provider >= 4.31.0, required_version >= 1.0.0
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.31.0"
      configuration_aliases = [
        aws.principal,
        aws.secondary,
      ]
    }
  }
}
