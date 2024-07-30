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

variable "spoke_vnet_id" {
  type        = string
  description = "The ID of the spoke VNET"
  default     = null
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "The ID of the subnet where the private endpoint should be created"
  default     = null
}

variable "web_application_principal_id" {
  type        = string
  description = "The principal id of the identity of the entra application"
}

variable "container_app_identity_principal_id" {
  type        = string
  description = "The principal id of the identity of the container app"
}

variable "capacity" {
  type        = number
  description = "The capacity of the Service Bus namespace prod instance"
  default     = 1
}