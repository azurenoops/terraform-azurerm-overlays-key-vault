# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

data "azuread_group" "admin_group" {
  display_name = "MPE Lab Admins"
}