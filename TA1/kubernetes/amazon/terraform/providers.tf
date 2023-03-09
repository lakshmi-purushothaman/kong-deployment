provider "aws" {
  version = "~> 4.15.0"
  region  = var.region
}

terraform {
  required_version = "~> 1.4.0"
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.6.0"
    }
  }
}
