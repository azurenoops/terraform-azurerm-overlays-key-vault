# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------
# Azure Region Lookup
#----------------------------------------------------------
module "mod_azure_region_lookup" {
  source  = "azurenoops/overlays-azregions-lookup/azurerm"
  version = "~> 1.0.0"

  azure_region = "eastus"
}

data "azuread_group" "admin_group" {
  display_name = "azure-platform-owners"
}

module "key_vault" {
  #source  = "azurenoops/overlays-key-vault/azurerm"
  #version = "x.x.x"
  source = "../.."

  # By default, this module will create a resource group and 
  # provide a name for an existing resource group. If you wish 
  # to use an existing resource group, change the option 
  # to "create_key_vault_resource_group = false." The location of the group 
  # will remain the same if you use the current resource.
  create_key_vault_resource_group = true
  location                        = module.mod_azure_region_lookup.location_cli
  environment                     = "public"
  deploy_environment              = "dev"
  org_name                        = "anoa"
  workload_name                   = "kv"

  # This is to enable the features of the key vault
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false

  # This is to enable public access to the key vault, since we are using a private endpoint, we will disable it
  public_network_access_enabled = false
  
  # Creating Private Endpoint requires, VNet name to create a Private Endpoint
  # By default this will create a `privatelink.azurecr.io` DNS zone. if created in commercial cloud
  # To use existing subnet, specify `existing_subnet_id` with valid subnet id. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  # Private endpoints doesn't work If not using `existing_subnet_id` to create redis inside a specified VNet.
  enable_private_endpoint = false
  # existing_subnet_id      = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-anoa-dev-kv/providers/Microsoft.Network/virtualNetworks/vnet-anoa-dev-kv/subnets/snet-anoa-dev-kv"
  # virtual_network_name    = "vnet-anoa-dev-kv"
  # existing_private_dns_zone     = "demo.example.com"

  # Current user should be here to be able to create keys and secrets
  admin_objects_ids = [
    data.azuread_group.admin_group.id
  ]
  
  # This is to enable resource locks for the key vault. 
  enable_resource_locks = false

  # Tags for Azure Resources
  add_tags = {
    example = "basic deployment of key vault"
  }
}

