locals {

  #####################################
  # Shared Variables
  #####################################
  telemetryId = "142867D4-EF63-4A75-8832-C96EB2DAEF04-${var.location}"

  base_tags = {
    "terraform"         = true
    "environment"       = var.environment
    "application-name"  = var.application_name
    "contoso-version"   = "2.0"
    "app-pattern-name"  = "java-mwa"
    "azd-env-name"     = var.application_name
  }

  postgresql_sku_name = var.environment == "prod" ? "GP_Standard_D4s_v3" : "B_Standard_B1ms"

  myip = chomp(data.http.myip.response_body)
  mynetwork = "${cidrhost("${local.myip}/16", 0)}/16"
}
