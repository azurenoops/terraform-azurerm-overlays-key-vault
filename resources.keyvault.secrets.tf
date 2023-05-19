# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#-----------------------------------------------------------------------------------
# Keyvault Secret
#-----------------------------------------------------------------------------------
/* resource "azurerm_key_vault_secret" "keys" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value != "" ? each.value : random_password.passwd[each.key].result
  key_vault_id = azurerm_key_vault.keyvault.id

  lifecycle {
    ignore_changes = [
      tags,
      value,
    ]
  }
} */
