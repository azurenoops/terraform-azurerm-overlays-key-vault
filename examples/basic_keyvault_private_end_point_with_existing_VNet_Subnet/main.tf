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

module "mod_key_vault" {
  depends_on = [
    azurerm_resource_group.kv_rg,
    azurerm_virtual_network.kv_vnet,
    azurerm_subnet.kv_subnet,
  ]
  #source  = "azurenoops/overlays-key-vault/azurerm"
  #version = "x.x.x"
  source = "../.."

  # By default, this module will create a resource group and 
  # provide a name for an existing resource group. If you wish 
  # to use an existing resource group, change the option 
  # to "create_key_vault_resource_group = false." The location of the group 
  # will remain the same if you use the current resource.
  existing_resource_group_name = azurerm_resource_group.kv_rg.name
  location                     = "eastus"
  environment                  = "public"
  deploy_environment           = "dev"
  org_name                     = "anoa"
  workload_name                = "kv"

  # This is to enable the features of the key vault
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false

  # This is to enable public access to the key vault, since we are using a private endpoint, we will disable it
  public_network_access_enabled = false

   # Once `Purge Protection` has been Enabled it's not possible to Disable it
  # Deleting the Key Vault with `Purge Protection` enabled will schedule the Key Vault to be deleted
  # The default retention period is 90 days, possible values are from 7 to 90 days
  # use `soft_delete_retention_days` to set the retention period
  enable_purge_protection = false
  # soft_delete_retention_days = 90

  # Creating Private Endpoint requires, VNet name to create a Private Endpoint
  # By default this will create a `privatelink.vaultcore.azure.net` DNS zone. if created in commercial cloud
  # To use existing subnet, specify `existing_subnet_id` with valid subnet id. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  # Private endpoints doesn't work If not using `existing_subnet_id` to create redis inside a specified VNet.
  enable_private_endpoint = true
  virtual_network_name    = azurerm_virtual_network.kv_vnet.name
  existing_subnet_id = ""

  # Current user should be here to be able to create keys and secrets
  admin_objects_ids = [
    data.azuread_group.admin_group.id
  ]

  # This is to enable resource locks for the key vault. 
  enable_resource_locks = false

  # Tags for Azure Resources
  add_tags = local.tags
}

