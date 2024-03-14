# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#-----------------------------------------------------------------------------------
# Keyvault Secret - Default is "false"
#-----------------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "secrets" {
  for_each        = { for secret in var.secrets : secret.name => secret }
  key_vault_id    = azurerm_key_vault.this.0.id
  name            = each.value.name
  value           = each.value.value
  content_type    = each.value.content_type
  not_before_date = each.value.not_before_date
  expiration_date = each.value.expiration_date
}
