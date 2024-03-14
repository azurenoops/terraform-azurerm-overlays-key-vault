# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

######################################
# Key Vault Secrets Configuration   ##
######################################

variable "secrets" {
  type = list(object({
    name            = string
    value           = string
    content_type    = optional(string)
    not_before_date = optional(string)
    expiration_date = optional(string)
  }))
  default     = []
  description = "List of objects that represent the configuration of each secrect."
}
