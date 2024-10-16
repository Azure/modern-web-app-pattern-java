# Create the App Config Keys

This will create the keys on `Azure App Configuration`. 

## Steps

1. Navigate to the `terraform-appconfig` directory on the jump box
   
   ```bash
   cd terraform-appconfig
   ```
1. Open the terraform.tfvars file in that folder and provide the correct values for the the following:

    * primary_app_config_id
    * secondary_app_config_id
    * primary_app_config_keys
    * secondary_app_config_keys

1. Create the App Config Keys

```bash
terraform init
terraform plan -out tfplan
terraform apply tfplan 
```