variable "key_vault_id" {
  description = "The ID of the Key Vault where secrets will be stored"
  type        = string
}

variable "secrets" {
  description = "Map of secrets to create"
  type        = map(string)
}