# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

######################################
# Key Vault Secrets Configuration   ##
######################################

variable "secrets" {
  type        = map(string)
  description = "A map of secrets for the Key Vault."
  default     = {}
}
