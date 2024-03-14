# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.22"
    }
    azurenoopsutils = {
      source  = "azurenoops/azurenoopsutils"
      version = "~> 1.0"
    }
  }
}

##----------------------------------------------------------------------------- 
## Provider block
## To be used only when there is existing private dns zone in different subscription. Mention other subscription id in 'var.alias_subscription_id'. 
##-----------------------------------------------------------------------------
provider "azurerm" {
  alias = "hub"
  features {}
  subscription_id = var.alias_subscription_id
}