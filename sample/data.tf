data "aws_vpc" "vpc_hefesto" {
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-vpc"]
  }
}

data "aws_subnet" "database_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-database-subnet-1"] 
  }
}

data "aws_subnet" "database_subnet_2" {
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-database-subnet-2"] 
  }
}


data "aws_subnet" "private_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-private-subnet-1"] 
  }
}

data "aws_subnet" "private_subnet_2" {
  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-subnet-private-subnet-2"] 
  }
}




data "aws_caller_identity" "current" {}

