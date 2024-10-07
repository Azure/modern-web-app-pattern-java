variable "resource_group" {
  type        = string
  description = "The resource group"
}

variable "environment" {
  type        = string
  description = "The environment (dev, test, prod...)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "The Azure region where all resources in this example should be created"
}

variable "application_name" {
  type        = string
  description = "The name of your application"
}

variable "features" {
  type = list(object({
    description = optional(string)
    name        = string
    enabled     = optional(bool, false)
    locked      = optional(bool, false)
    label       = optional(string)
  }))
  default = null

  description = "The features to create in the App Configuration"
}

variable "keys" {
  type = list(object({
    key                 = string
    content_type        = optional(string)
    label               = optional(string)
    value               = optional(string)
    locked              = optional(bool)
    type                = optional(string, "kv")
    vault_key_reference = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for k in var.keys :
      (k.type == "kv" && k.value != null) || (k.type == "vault" && k.vault_key_reference != null)
    ])
    error_message = "Type must be kv or vault. If vault, vault_key_reference must be set. If kv, value must be set."
  }

  description = "The keys to create in the App Configuration"
}

variable "replica_location" {
  type        = string
  description = "The location of the replica"
  default     = null
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "The ID of the subnet where the private endpoint should be created"
  default     = null
}

variable "spoke_vnet_id" {
  type        = string
  description = "The ID of the Spoke VNET"
  default     = null
}

variable "app_service_identity_principal_id" {
  type        = string
  description = "The User Assigned identity id of the App Service"
}
