terraform {
  required_version = ">= 0.13"
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = ">=3.5.11"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.6.0"
    }
  }
}
