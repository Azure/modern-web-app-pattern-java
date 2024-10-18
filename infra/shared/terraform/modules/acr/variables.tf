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
    #virtual_network_subnet_ids = optional(list(string))
  })

  default = null
}

variable "georeplications" {
  type = list(object({
    location = string
  }))
  default = []
}

