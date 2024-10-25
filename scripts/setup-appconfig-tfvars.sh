# This script depends on the following environment variables:
# - primary_app_config_id
# - secondary_app_config_id
# - primary_app_config_keys
# - secondary_app_config_keys

# Project
readonly PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

source $PROJECT_ROOT/deployment-env

TERRAFORM_VARS_FILE=$PROJECT_ROOT/infra/terraform-appconfig/terraform.tfvars

echo "Setting up Terraform variables for App Configuration..."
echo "------------------------------"

echo "primary_app_config_id = \"$primary_app_config_id\"" > $TERRAFORM_VARS_FILE
echo "secondary_app_config_id = \"$secondary_app_config_id\"" >> $TERRAFORM_VARS_FILE
echo "primary_app_config_keys = ${primary_app_config_keys}" >> $TERRAFORM_VARS_FILE
echo "secondary_app_config_keys = ${secondary_app_config_keys}" >> $TERRAFORM_VARS_FILE