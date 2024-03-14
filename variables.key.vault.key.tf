# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

##################################
# Key Vault Key Configuration   ##
##################################

variable "keys" {
  type = list(object({
    name            = string
    key_type        = string
    key_size        = optional(number)
    curve           = optional(string)
    key_opts        = optional(list(string), [])
    not_before_date = optional(string)
    expiration_date = optional(string)
  }))
  default     = []
  description = "List of objects that represent the configuration of each key."
}