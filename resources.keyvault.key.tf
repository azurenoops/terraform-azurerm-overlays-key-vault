# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Key Vault configuration Key - Default (required). 
#------------------------------------------------------------
resource "azurerm_key_vault_key" "keys" {
  for_each        = { for key in var.keys : key.name => key }
  key_vault_id    = azurerm_key_vault.this.0.id
  name            = each.value.name
  key_type        = each.value.key_type
  key_size        = each.value.key_size
  curve           = each.value.curve
  key_opts        = each.value.key_opts
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date
}
