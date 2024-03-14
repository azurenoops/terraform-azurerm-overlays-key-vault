
resource "azurerm_resource_group" "kv_rg" {
  name     = "rg-kv"
  location = module.mod_azure_region_lookup.location_cli
}

resource "azurerm_virtual_network" "kv_vnet" {
  name                = "vnet-kv"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.kv_rg.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "kv_subnet" {
  name                 = "snet-kv"
  resource_group_name  = azurerm_resource_group.kv_rg.name
  virtual_network_name = azurerm_virtual_network.kv_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-kv"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.kv_rg.name
  sku                 = "PerGB2018"
}
