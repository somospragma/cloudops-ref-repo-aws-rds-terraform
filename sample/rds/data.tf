data "aws_vpc" "vpc_hefesto_p" {
  provider = aws.principal
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-vpc"]
  }
}

data "aws_subnet" "database_subnet_1_p" {
  provider = aws.principal
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-database-1"] 
  }
}

data "aws_subnet" "database_subnet_2_p" {
  provider = aws.principal
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-database-2"] 
  }
}

data "aws_subnet" "private_subnet_1_p" {
  provider = aws.principal
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-private-1"] 
  }
}

data "aws_subnet" "private_subnet_2_p" {
  provider = aws.principal
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-private-2"] 
  }
}

data "aws_security_group" "rds_security_group_p" {
  provider = aws.principal
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-sg-rds-bs"] 
  }
}

data "aws_vpc" "vpc_hefesto_s" {
  provider = aws.secondary
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-vpc"]
  }
}

data "aws_subnet" "database_subnet_1_s" {
  provider = aws.secondary
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-database-1"] 
  }
}

data "aws_subnet" "database_subnet_2_s" {
  provider = aws.secondary
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-database-2"] 
  }
}

data "aws_subnet" "private_subnet_1_s" {
  provider = aws.secondary
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-private-1"] 
  }
}

data "aws_subnet" "private_subnet_2_s" {
  provider = aws.secondary
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-private-2"] 
  }
}

data "aws_security_group" "rds_security_group_s" {
  provider = aws.secondary
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-sg-rds-bs"] 
  }
}

data "aws_caller_identity" "current" {}

# Test secret manager

data "aws_secretsmanager_secret" "example_p" {
  provider = aws.principal
  name = "dev/rds/aurora/serverless" # Replace with your secret name
}

data "aws_secretsmanager_secret_version" "current_p" {
  provider = aws.principal
  secret_id = data.aws_secretsmanager_secret.example_p.id
}

data "aws_secretsmanager_secret" "example_s" {
  provider = aws.secondary
  name = "dev/rds/aurora/serverless" # Replace with your secret name
}

data "aws_secretsmanager_secret_version" "current_s" {
  provider = aws.secondary
  secret_id = data.aws_secretsmanager_secret.example_s.id
}