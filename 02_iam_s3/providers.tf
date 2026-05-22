terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "manager-terraform-agr" # Cambia esto si usaste un nombre de perfil específico. En este caso se utilizó usuario Master.
} 