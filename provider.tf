# =========================================
# TERRAFORM CONFIGURATION
# =========================================

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.12.0"
    }
  }
}

# =========================================
# AZURE PROVIDER CONFIGURATION
# =========================================

provider "azurerm" {
  features {}
}
