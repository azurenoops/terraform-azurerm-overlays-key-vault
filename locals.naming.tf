# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  resource_group_name = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, module.mod_key_vault_rg.*.resource_group_name, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, module.mod_key_vault_rg.*.resource_group_location, [""]), 0)
  kv_name                = coalesce(var.custom_kv_name, data.azurenoopsutils_resource_name.keyvault.result)
  hsm_name            = coalesce(var.custom_hsm_name, data.azurenoopsutils_resource_name.keyvault_hsm.result)
  private_dns_a_record_name = coalesce(var.custom_private_dns_a_record_name, data.azurenoopsutils_resource_name.keyvault_dns_a_record.result)
}
