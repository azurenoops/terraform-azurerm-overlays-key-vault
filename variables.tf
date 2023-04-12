# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

###########################
# Global Configuration   ##
###########################

variable "environment" {
  description = "The Terraform backend environment e.g. public or usgovernment"
  type        = string
  default     = null
}

variable "location" {
  description = "The location/region to keep all your network resources. To get the list of all locations with table format from azure cli, run 'az account list-locations -o table'"
  type        = string
}

variable "org_name" {
  description = "A name for the organization. It defaults to anoa."
  type        = string
  default     = "anoa"
}

variable "workload_name" {
  description = "A name for the workload. It defaults to fd-cdn."
  type        = string
  default     = "fd-cdn"
}

variable "deploy_environment" {
  description = "The environment to deploy. It defaults to dev."
  type        = string
  default     = "dev"
}

#######################
# RG Configuration   ##
#######################

variable "create_key_vault_resource_group" {
  description = "Controls if the resource group should be created. If set to false, the resource group name must be provided. Default is true."
  type        = bool
  default     = true
}

variable "existing_resource_group_name" {
  description = "The name of the existing resource group to use. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables."
  type        = string
  default     = null
}

variable "use_location_short_name" {
  description = "Use short location name for resources naming (ie eastus -> eus). Default is true. If set to false, the full cli location name will be used. if custom naming is set, this variable will be ignored."
  type        = bool
  default     = true
}

#####################################
# Private Endpoint Configuration   ##
#####################################

variable "enable_private_endpoint" {
  description = "Manages a Private Endpoint to Azure Container Registry. Default is false."
  default     = false
}

variable "existing_private_dns_zone" {
  description = "Name of the existing private DNS zone"
  default     = null
}

variable "private_subnet_address_prefix" {
  description = "The name of the subnet for private endpoints"
  default     = null
}

variable "virtual_network_name" {
  description = "Name of the virtual network for the private endpoint"
  default     = null
}

variable "existing_vnet_id" {
  description = "ID of the existing virtual network for the private endpoint"
  default     = null
}

variable "existing_subnet_id" {
  description = "The resource id of existing subnet"
  default     = null
}

###############################
# Key Vault Configuration   ##
###############################

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID that should be used for authenticating requests to the Key Vault. Default is the current one."
  type        = string
  default     = ""
}

variable "sku_name" {
  description = "The Name of the SKU used for this Key Vault. Possible values are \"standard\" and \"premium\"."
  type        = string
  default     = "standard"
}

variable "enabled_for_deployment" {
  description = "Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the Key Vault."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "Whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "Whether Azure Resource Manager is permitted to retrieve secrets from the Key Vault."
  type        = bool
  default     = false
}

variable "admin_objects_ids" {
  description = "IDs of the objects that can do all operations on all keys, secrets and certificates."
  type        = list(string)
  default     = []
}

variable "reader_objects_ids" {
  description = "IDs of the objects that can read all keys, secrets and certificates."
  type        = list(string)
  default     = []
}

variable "public_network_access_enabled" {
  description = "Whether the Key Vault is available from public network."
  type        = bool
  default     = false
}

variable "network_acls" {
  description = "Object with attributes: `bypass`, `default_action`, `ip_rules`, `virtual_network_subnet_ids`. Set to `null` to disable. See https://www.terraform.io/docs/providers/azurerm/r/key_vault.html#bypass for more information."
  type = object({
    bypass                     = optional(string, "None"),
    default_action             = optional(string, "Deny"),
    ip_rules                   = optional(list(string)),
    virtual_network_subnet_ids = optional(list(string)),
  })
  default = {}
}

variable "purge_protection_enabled" {
  description = "Whether to activate purge protection."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "The number of days that items should be retained for once soft-deleted. This value can be between `7` and `90` days."
  type        = number
  default     = 7
}

variable "rbac_authorization_enabled" {
  type        = bool
  description = "Whether the Key Vault uses Role Based Access Control (RBAC) for authorization of data actions instead of access policies."
  default     = false
}