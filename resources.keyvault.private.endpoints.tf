# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------
# Private Link for Sql - Default is "false" 
#---------------------------------------------------------
data "azurerm_virtual_network" "vnet" {
  count               = var.enable_private_endpoint && var.existing_vnet_id == null ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "snet_ep" {
  count                                     = var.enable_private_endpoint && var.existing_subnet_id == null ? 1 : 0
  name                                      = "snet-endpoint-${local.location}"
  resource_group_name                       = var.existing_vnet_id == null ? data.azurerm_virtual_network.vnet.0.resource_group_name : element(split("/", var.existing_vnet_id), 4)
  virtual_network_name                      = var.existing_vnet_id == null ? data.azurerm_virtual_network.vnet.0.name : element(split("/", var.existing_vnet_id), 8)
  address_prefixes                          = var.private_subnet_address_prefix
  private_endpoint_network_policies_enabled = true
}

resource "azurerm_private_endpoint" "pep" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-private-endpoint", element([for n in azurerm_key_vault.keyvault : n.name], 0))
  location            = local.location
  resource_group_name = local.resource_group_name
  subnet_id           = var.existing_subnet_id == null ? azurerm_subnet.snet_ep.0.id : var.existing_subnet_id
  tags                = merge({ "Name" = format("%s-private-endpoint", element([for n in azurerm_key_vault.keyvault : n.name], 0)) }, var.add_tags, )

  private_service_connection {
    name                           = "keyvault-privatelink"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.keyvault.0.id
    subresource_names              = ["vault"]
  }
}

#------------------------------------------------------------------
# DNS zone & records for SQL Private endpoints - Default is "false" 
#------------------------------------------------------------------
data "azurerm_private_endpoint_connection" "pip" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep.0.name
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_key_vault.keyvault]
}

resource "azurerm_private_dns_zone" "dns_zone" {
  count               = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = var.environment == "public" ? "privatelink.vaultcore.azure.net" : "privatelink.vaultcore.usgovcloudapi.net"
  resource_group_name = local.resource_group_name
  tags                = merge({ "Name" = format("%s", "Azure-Key-Vault-Private-DNS-Zone") }, var.add_tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  count                 = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                  = "vnet-private-zone-link"
  resource_group_name   = local.resource_group_name
  private_dns_zone_name = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dns_zone.0.name : var.existing_private_dns_zone
  virtual_network_id    = var.existing_vnet_id == null ? data.azurerm_virtual_network.vnet.0.id : var.existing_vnet_id
  registration_enabled  = false
  tags                  = merge({ "Name" = format("%s", "vnet-private-zone-link") }, var.add_tags, )
}

resource "azurerm_private_dns_a_record" "a_rec" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = lower(azurerm_key_vault.keyvault.0.name)
  zone_name           = var.existing_private_dns_zone == null ? azurerm_private_dns_zone.dns_zone.0.name : var.existing_private_dns_zone
  resource_group_name = local.resource_group_name
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.pip.0.private_service_connection.0.private_ip_address]
}