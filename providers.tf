terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}


provider "azurerm" {
  features {}
}

provider "aws" {
  region  = "eu-west-1"
  profile = "my-dev"

  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "dev"
      Role        = "k8s"
    }
  }
}
