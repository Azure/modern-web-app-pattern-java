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

variable "ip_rules" {
  description = "The IP rules for the storage account network rules."
  type        = list(string)
}

variable "principal_id" {
  description = "The principal ID for role assignments."
  type        = string
}