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

variable "log_analytics_workspace_id" {
  type        = string
  description = "The ID of the Log Analytics workspace"
}

variable "acr_login_server" {
  type        = string
  description = "The login server of the Azure Container Registry"
}

variable "container_registry_user_assigned_identity_id" {
  type        = string
  description = "The ID of the user-assigned identity for the Azure Container Registry"
}

variable "servicebus_namespace_primary_connection_string" {
  type        = string
  description = "The primary connection string of the Azure Service Bus namespace"
}

variable "servicebus_namespace" {
  type        = string
  description = "The name of the Azure Service Bus namespace"
}

variable "email_request_queue_name" {
  type        = string
  description = "The name of the email request queue"
}

variable "email_response_queue_name" {
  type        = string
  description = "The name of the email response queue"
}

variable "isNetworkIsolated" {
  type        = bool
  description = "Indicates if the container app should be network isolated"
  default     = false
}

variable "infrastructure_subnet_id" {
  type        = string
  description = "The ID of the subnet where the infrastructure resources should be created"
  default     = null
}

variable "spoke_vnet_id" {
  type        = string
  description = "The ID of the spoke VNET"
  default     = null
}