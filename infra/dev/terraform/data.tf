data "azuread_client_config" "current" {}

data "http" "myip" {
  url = "https://api.ipify.org"
}
