# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#-----------------------------------------------------------------------------------
# Keyvault Secret - Default is "false"
#-----------------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "keys" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.keyvault.0.id

  lifecycle {
    ignore_changes = [
      tags,
      value,
    ]
  }
}
