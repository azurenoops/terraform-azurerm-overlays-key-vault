# Azure Key Vault Overlay Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/azurenoops/overlays-key-vault/azurerm/)

This Terraform Module creates a Key Vault also adds required access policies for azure AD users, groups and azure AD service principals. This also enables private endpoint and sends all logs to log analytic workspace or storage. This module can be used with an [SCCA compliant Network](https://registry.terraform.io/modules/azurenoops/overlays-management-hub/azurerm/latest).

## SCCA Compliance

This module can be SCCA compliant and can be used in a SCCA compliant Network. Enable private endpoints and SCCA compliant network rules to make it SCCA compliant.

For more information, please read the [SCCA documentation]("https://www.cisa.gov/secure-cloud-computing-architecture").

## Contributing

If you want to contribute to this repository, feel free to to contribute to our Terraform module.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Resources Used

* [Acess Polices for AD users, groups and SPN](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy)
* [Secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret)
* [Certifiate Contacts](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault#contact)
* [Private Endpoints](https://www.terraform.io/docs/providers/azurerm/r/private_endpoint.html)
* [Private DNS zone for `privatelink` A records](https://www.terraform.io/docs/providers/azurerm/r/private_dns_zone.html)
* [Azure Reource Locks](https://www.terraform.io/docs/providers/azurerm/r/management_lock.html)

## Overlay Module Usage

```terraform
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "mod_key_vault" {
  source  = "azurenoops/overlays-key-vault/azurerm"
  version = "x.x.x"

  # By default, this module will create a resource group and 
  # provide a name for an existing resource group. If you wish 
  # to use an existing resource group, change the option 
  # to "create_key_vault_resource_group = false." The location of the group 
  # will remain the same if you use the current resource.
  create_key_vault_resource_group = true
  location                        = module.mod_azure_region_lookup.location_cli
  environment                     = "public"
  deploy_environment              = "dev"
  org_name                        = "anoa"
  workload_name                   = "kv"

  # This is to enable the features of the key vault
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false

  # This is to enable public access to the key vault, since we are using a private endpoint, we will disable it
  public_network_access_enabled = false
  
  # Creating Private Endpoint requires, VNet name to create a Private Endpoint
  # By default this will create a `privatelink.azurecr.io` DNS zone. if created in commercial cloud
  # To use existing subnet, specify `existing_subnet_id` with valid subnet id. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  # Private endpoints doesn't work If not using `existing_subnet_id` to create redis inside a specified VNet.
  enable_private_endpoint = false
  # existing_subnet_id      = "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-anoa-dev-kv/providers/Microsoft.Network/virtualNetworks/vnet-anoa-dev-kv/subnets/snet-anoa-dev-kv"
  # virtual_network_name    = "vnet-anoa-dev-kv"
  # existing_private_dns_zone     = "demo.example.com"

  # Current user should be here to be able to create keys and secrets
  admin_objects_ids = [
    data.azuread_group.admin_group.id
  ]
  
  # This is to enable resource locks for the key vault. 
  enable_resource_locks = false

  # Tags for Azure Resources
  add_tags = {
    example = "basic deployment of key vault"
  }
}
```

## Key Vault Advanced features

### `enabled_for_deployment`

To use Key Vault with Azure Resource Manager virtual machines, the `enabled_for_deployment` property on Key Vault must be set to `true`. This access is enabled by default for this module. Incase you want to disable it set the argument `enabled_for_deployment = "false"`.

### `enabled_for_disk_encryption`

We can configure Azure Disk Encryption to use Azure Key Vault to control and manage disk encryption keys and secrets. This access is enabled by default for this module. Incase you want to disable it set the argument `enabled_for_disk_encryption = "false"`.

> Warning: The key vault and VMs must be in the same subscription. Also, to ensure that encryption secrets don't cross regional boundaries, Azure Disk Encryption requires the Key Vault and the VMs to be co-located in the same region. Create and use a Key Vault that is in the same subscription and region as the VMs to be encrypted.

### `enabled_for_template_deployment`

When you need to pass a secure value (like a password) as a parameter during deployment, you can retrieve the value from an Azure Key Vault. To access the Key Vault when deploying Managed Applications, you must grant access to the Appliance Resource Provider service principal. This access is enabled by default for this module. Incase you want to disable it set the argument `enabled_for_template_deployment = "false"`.

### Soft-Delete and Purge Protection

Soft-delete is enabled by default. When enabled, resources marked as deleted resources are retained for a specified period (90 days by default). The service further provides a mechanism for recovering the deleted object, essentially undoing the deletion.

Purge protection is an optional Key Vault behavior and is not enabled by default. Purge protection can only be enabled once soft-delete is enabled. It can be turned on using this module by setting the argument `enable_purge_protection = true`.

When purge protection is on, a vault or an object in the deleted state cannot be purged until the retention period has passed. Soft-deleted vaults and objects can still be recovered, ensuring that the retention policy will be followed. Soft delete retention can be updated using  `soft_delete_retention_days` argument with a valid days.

> The default retention period is 90 days for the soft-delete and the purge protection retention policy uses the same interval. Once set, the retention policy interval cannot be changed.

## Configure Azure Key Vault firewalls and virtual networks

Configure Azure Key Vault firewalls and virtual networks to restrict access to the key vault. The virtual network service endpoints for Key Vault (Microsoft.KeyVault) allow you to restrict access to a specified virtual network and set of IPv4 address ranges.

Default action is set to `Allow` when no network rules matched. A `virtual_network_subnet_ids` or `ip_rules` can be added to `network_acls` block to allow request that is not Azure Services.

```hcl
module "key-vault" {
  source  = "azurenoops/overlays-key-vault/azurerm"
  version = "x.x.x"

  # .... omitted

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"

    # One or more IP Addresses, or CIDR Blocks to access this Key Vault.
    ip_rules                   = ["123.201.18.148"]

    # One or more Subnet ID's to access this Key Vault.
    virtual_network_subnet_ids = []
  }
  
# ....omitted

}
```

## Private Endpoint - Integrate Key Vault with Azure Private Link

Azure Private Endpoint is a network interface that connects you privately and securely to a service powered by Azure Private Link. Private Endpoint uses a private IP address from your VNet, effectively bringing the service into your VNet.

With Private Link, Microsoft offering the ability to associate a logical server to a specific private IP address (also known as private endpoint) within the VNet. Clients can connect to the Private endpoint from the same VNet, peered VNet in same region, or via VNet-to-VNet connection across regions. Additionally, clients can connect from on-premises using ExpressRoute, private peering, or VPN tunneling.

By default, this feature not enabled on this module. To create private link with private endpoints set the variable `enable_private_endpoint` to `true` and provide `virtual_network_name`, `private_subnet_address_prefix` with a valid values. You can also use the existing private DNS zone to create DNS records. To use this feature, set the `existing_private_dns_zone` with a valid existing private DNS zone name.

```terraform
module "key-vault" {
  source  = "azurenoops/overlays-key-vault/azurerm"
  version = "x.x.x"

  # .... omitted

  # Creating Private Endpoint requires, VNet name and address prefix to create a subnet
  # By default this will create a `privatelink.vaultcore.azure.net` DNS zone. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  enable_private_endpoint       = true
  virtual_network_name          = "vnet-shared-hub-westeurope-001"
  private_subnet_address_prefix = ["10.1.5.0/27"]
  # existing_private_dns_zone     = "demo.example.com"

  # ....omitted

}
```

If you want to use eixsting VNet and Subnet to create a private endpoints, set a variable `enable_private_endpoint` to `true` and provide `virtual_network_name`, `existing_subnet_id` with a valid resource ids. You can also use the existing private DNS zone to create DNS records. To use this feature, set the `existing_private_dns_zone` with a valid existing private DNS zone name.

```terraform
module "key-vault" {
  source  = "azurenoops/overlays-key-vault/azurerm"
  version = "x.x.x"

  # .... omitted

  # Creating Private Endpoint requires, VNet name and address prefix to create a subnet
  # By default this will create a `privatelink.vaultcore.azure.net` DNS zone. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name
  enable_private_endpoint      = true
  virtual_network_name         = data.azurerm_virtual_network.example.name
  existing_subnet_id           = data.azurerm_subnet.example.id
  # existing_private_dns_zone  = "demo.example.com"

  # ....omitted

}
```

For more details: [Integrate Key Vault with Azure Private Link](https://docs.microsoft.com/en-us/azure/key-vault/general/private-link-service?tabs=portal)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_azurenoopsutils"></a> [azurenoopsutils](#requirement\_azurenoopsutils) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.22 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurenoopsutils"></a> [azurenoopsutils](#provider\_azurenoopsutils) | ~> 1.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.22 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mod_azure_region_lookup"></a> [mod\_azure\_region\_lookup](#module\_mod\_azure\_region\_lookup) | azurenoops/overlays-azregions-lookup/azurerm | ~> 1.0.0 |
| <a name="module_mod_key_vault_rg"></a> [mod\_key\_vault\_rg](#module\_mod\_key\_vault\_rg) | azurenoops/overlays-resource-group/azurerm | ~> 1.0.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.keyvault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_access_policy.admin_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_access_policy.readers_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [azurerm_key_vault_managed_hardware_security_module.keyvault_hsm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_managed_hardware_security_module) | resource |
| [azurerm_management_lock.storage_account_level_lock](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_private_dns_a_record.a_rec](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_a_record) | resource |
| [azurerm_private_dns_zone.dns_zone](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.vnet_link](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_private_endpoint.pep](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) | resource |
| [azurerm_role_assignment.rbac_keyvault_administrator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.rbac_keyvault_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.rbac_keyvault_secrets_users](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurenoopsutils_resource_name.keyvault](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurenoopsutils_resource_name.keyvault_hsm](https://registry.terraform.io/providers/azurenoops/azurenoopsutils/latest/docs/data-sources/resource_name) | data source |
| [azurerm_client_config.current_config](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_private_endpoint_connection.pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/private_endpoint_connection) | data source |
| [azurerm_resource_group.rgrp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_tags"></a> [add\_tags](#input\_add\_tags) | Map of custom tags. | `map(string)` | `{}` | no |
| <a name="input_admin_objects_ids"></a> [admin\_objects\_ids](#input\_admin\_objects\_ids) | IDs of the objects that can do all operations on all keys, secrets and certificates. | `list(string)` | `[]` | no |
| <a name="input_create_key_vault_resource_group"></a> [create\_key\_vault\_resource\_group](#input\_create\_key\_vault\_resource\_group) | Controls if the resource group should be created. If set to false, the resource group name must be provided. Default is true. | `bool` | `true` | no |
| <a name="input_custom_name"></a> [custom\_name](#input\_custom\_name) | Name of the Key Vault, generated if not set. | `string` | `""` | no |
| <a name="input_custom_resource_group_name"></a> [custom\_resource\_group\_name](#input\_custom\_resource\_group\_name) | The name of the custom resource group to create. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_default_tags_enabled"></a> [default\_tags\_enabled](#input\_default\_tags\_enabled) | Option to enable or disable default tags. | `bool` | `true` | no |
| <a name="input_deploy_environment"></a> [deploy\_environment](#input\_deploy\_environment) | The environment to deploy. It defaults to dev. | `string` | `"dev"` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Manages a Private Endpoint to Azure Key Vault. Default is false. | `bool` | `false` | no |
| <a name="input_enable_resource_locks"></a> [enable\_resource\_locks](#input\_enable\_resource\_locks) | (Optional) Enable resource locks | `bool` | `false` | no |
| <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment) | Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault. | `bool` | `false` | no |
| <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption) | Whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. | `bool` | `false` | no |
| <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment) | Whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault. | `bool` | `false` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The Terraform backend environment e.g. public or usgovernment | `string` | `null` | no |
| <a name="input_existing_private_dns_zone"></a> [existing\_private\_dns\_zone](#input\_existing\_private\_dns\_zone) | Name of the existing private DNS zone | `any` | `null` | no |
| <a name="input_existing_subnet_id"></a> [existing\_subnet\_id](#input\_existing\_subnet\_id) | ID of the existing subnet for the private endpoint | `any` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table' | `string` | n/a | yes |
| <a name="input_lock_level"></a> [lock\_level](#input\_lock\_level) | (Optional) id locks are enabled, Specifies the Level to be used for this Lock. | `string` | `"CanNotDelete"` | no |
| <a name="input_managed_hardware_security_module_enabled"></a> [managed\_hardware\_security\_module\_enabled](#input\_managed\_hardware\_security\_module\_enabled) | Create a KeyVault Managed HSM resource if enabled. Changing this forces a new resource to be created. | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Optional prefix for the generated name | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Optional suffix for the generated name | `string` | `""` | no |
| <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls) | Object with attributes: `bypass`, `default_action`, `ip_rules`, `virtual_network_subnet_ids`. Set to `null` to disable. See <https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#bypass> for more information. | <pre>object({<br>    bypass                     = optional(string, "None"),<br>    default_action             = optional(string, "Deny"),<br>    ip_rules                   = optional(list(string)),<br>    virtual_network_subnet_ids = optional(list(string)),<br>  })</pre> | `{}` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | A name for the organization. It defaults to anoa. | `string` | `"anoa"` | no |
| <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled) | Whether the Key Vault is available from public network. | `bool` | `false` | no |
| <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled) | Whether to activate purge protection. | `bool` | `true` | no |
| <a name="input_rbac_authorization_enabled"></a> [rbac\_authorization\_enabled](#input\_rbac\_authorization\_enabled) | Whether the Key Vault uses Role Based Access Control (RBAC) for authorization of data actions instead of access policies. | `bool` | `false` | no |
| <a name="input_reader_objects_ids"></a> [reader\_objects\_ids](#input\_reader\_objects\_ids) | IDs of the objects that can read all keys, secrets and certificates. | `list(string)` | `[]` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | The Name of the SKU used for this Key Vault. Possible values are "standard" and "premium". | `string` | `"standard"` | no |
| <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days) | The number of days that items should be retained for once soft-deleted. This value can be between `7` and `90` days. | `number` | `7` | no |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault. Default is the current one. | `string` | `""` | no |
| <a name="input_use_location_short_name"></a> [use\_location\_short\_name](#input\_use\_location\_short\_name) | Use short location name for resources naming (ie eastus -> eus). Default is true. If set to false, the full cli location name will be used. if custom naming is set, this variable will be ignored. | `bool` | `true` | no |
| <a name="input_use_naming"></a> [use\_naming](#input\_use\_naming) | Use the Azure CAF naming provider to generate default resource name. `custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the virtual network for the private endpoint | `any` | `null` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | A name for the workload. It defaults to fd-cdn. | `string` | `"fd-cdn"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_vault_hsm_uri"></a> [key\_vault\_hsm\_uri](#output\_key\_vault\_hsm\_uri) | The URI of the Key Vault Managed Hardware Security Module, used for performing operations on keys. |
| <a name="output_key_vault_id"></a> [key\_vault\_id](#output\_key\_vault\_id) | ID of the Key Vault. |
| <a name="output_key_vault_name"></a> [key\_vault\_name](#output\_key\_vault\_name) | Name of the Key Vault. |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | URI of the Key Vault |
<!-- END_TF_DOCS -->