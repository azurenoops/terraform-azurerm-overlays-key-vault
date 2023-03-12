# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------------
# Azure Key Vault Lock configuration - Default (required). 
#------------------------------------------------------------------
resource "azurerm_management_lock" "storage_account_level_lock" {
  count      = var.enable_resource_locks ? 1 : 0
  name       = "${local.kv_name}-${var.lock_level}-lock"
  scope      = azurerm_key_vault.keyvault[0].id
  lock_level = var.lock_level
  notes      = "Azure Key Vault '${local.kv_name}' is locked with '${var.lock_level}' level."
}
