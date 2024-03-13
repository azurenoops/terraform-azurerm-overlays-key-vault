# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# 
locals {
  tenant_id = coalesce(
    var.tenant_id,
    data.azurerm_client_config.current_config.tenant_id,
  )  
}

##-----------------------------------------------------------------------------
## Locals declaration for determining the local variables
##-----------------------------------------------------------------------------
locals {
  valid_rg_name         = var.existing_private_dns_zone == null ? local.resource_group_name : var.existing_private_dns_zone_resource_group_name
  private_dns_zone_name = var.enable_private_endpoint ? var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dns_zone[0].name : var.existing_private_dns_zone : null
}