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
  type = list(object({
    default_action = string
    ip_rules = list(object({
      action   = string
      ip_range = list(string)
    }))
  }))

  default = [{
    default_action = "Allow"
    ip_rules       = []
  }]
}

variable "georeplications" {
  type = list(object({
    location = string
  }))
  default = []
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "The ID of the subnet where the private endpoint should be created"
}

variable "private_endpoint_vnet_id" {
  type        = string
  description = "The ID of the VNet where the private endpoint should be created"
}