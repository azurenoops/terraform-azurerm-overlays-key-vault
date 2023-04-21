
resource "azurerm_resource_group" "kv_rg" {
  name     = "rg-kv"
  location = module.mod_azure_region_lookup.location_cli
}

