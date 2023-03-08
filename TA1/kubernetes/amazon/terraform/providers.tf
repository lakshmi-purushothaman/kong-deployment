provider "aws" {
  version = "~> 4.15.0"
  region  = var.region
}

terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.10.0"
    }
  }
  required_version = "~> 1.4.0"
}