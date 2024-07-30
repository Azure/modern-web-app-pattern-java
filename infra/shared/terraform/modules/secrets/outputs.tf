output "secret_names" {
  value = { for k, v in azurerm_key_vault_secret.key_vault_secret : k => v.id }
}