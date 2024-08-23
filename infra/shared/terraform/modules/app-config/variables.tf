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

variable "aca_identity_principal_id" {
  type        = string
  description = "The principal id of the identity of the container app"
}

variable "network_rules" {
  type = object({
    default_action = optional(string)
    ip_rules = optional(list(object({
      action   = string
      ip_range = string
    })), [])
  })

  default = null
}

variable "features" {
  type = list(object({
    description = string
    name        = string
    enabled     = bool
    locked      = bool
    label       = string
  }))
  default = null

  description = "The features to create in the App Configuration"
}

variable "keys" {
  type = list(object({
    key                 = string
    content_type        = string
    label               = string
    value               = string
    locked              = bool
    type                = string
    vault_key_reference = string
  }))
  default = []

  validation {
    condition = alltrue([
      for k in var.keys : (k.type == "kv" && (k.value != null && !empty(k.value))) || (k.type == "vault" && (k.vault_key_reference != null && !empty(k.vault_key_reference)))
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
