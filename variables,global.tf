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

variable "alias_subscription_id" {
  # To be set when you are using a DNS zone from different subscription.
  type        = string
  description = "Different subscription id for local provider(id of different sub in which DNS zone is present)."
  default     = null
}

#######################
# RG Configuration   ##
#######################

variable "create_key_vault_resource_group" {
  description = "Controls if the resource group should be created. If set to false, the resource group name must be provided. Default is true."
  type        = bool
  default     = false
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

variable "existing_private_subnet_name" {
  description = "Name of the existing private subnet for the private endpoint"
  default     = null
}

variable "existing_virtual_network_name" {
  description = "Name of the virtual network for the private endpoint"
  default     = null
}

variable "hub_virtual_network_name" {
  description = "Name of the hub virtual network for the private endpoint. This is used when the dns is in a hub subscription."
  type        = string
  default     = null
}

variable "existing_private_dns_zone_resource_group_name" {
  type        = string
  default     = ""
  description = "The name of the existing resource group"
}

variable "connect_to_dns_in_hub_subscription" {
  # To be set true when hosted DNS zone is in hub subnscription.
  type        = bool
  default     = false
  description = "Flag to tell whether dns zone is in hub subscription or not."
}

variable "hub_subscription_vnet_link" {
  type        = bool
  default     = false
  description = "Flag to control creation of vnet link for dns zone in hub subscription"
}

