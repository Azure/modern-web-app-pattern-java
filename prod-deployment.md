# Steps to deploy the production deployment

This section describes the deployment steps for the reference implementation of a modern web application pattern with Java on Microsoft Azure. These steps guide you through using the jump box that is deployed when performing a network isolated deployment because access to resources will be restricted from public network access and must be performed from a machine connected to the vnet.

![Diagram showing the network focused architecture of the reference implementation.](./docs/assets/diagrams/modern-web-app-java.svg)

## Prerequisites

We recommend that you use a Dev Container to deploy this application.  The requirements are as follows:

- [Azure Subscription](https://azure.microsoft.com/pricing/member-offers/msdn-benefits-details/).
- [Visual Studio Code](https://code.visualstudio.com/).
- [Docker Desktop](https://www.docker.com/get-started/).
- [Permissions to register an application in Microsoft Entra ID](https://learn.microsoft.com/azure/active-directory/develop/quickstart-register-app).
- Visual Studio Code [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers).

If you do not wish to use a Dev Container, please refer to the [prerequisites](prerequisites.md) for detailed information on how to set up your development system to build, run, and deploy the application.

> **Note**
>
> These steps are used to connect to a Linux jump box where you can deploy the code. The jump box is not designed to be a build server. You should use a devOps pipeline to manage build agents and deploy code into the environment. Also note that for this content the jump box is a Linux VM. This can be swapped with a Windows VM based on your organization's requirements.

## Steps to deploy the reference implementation

The following detailed deployment steps assume you are using a Dev Container inside Visual Studio Code.

### 1. Log in to Azure


1. Start a terminal in the dev container and authenticated to Azure and have the appropriate subscription selected. Run the following command to authenticate:

    ```sh
    az login
    ```

    If you have multiple tenants, you can use the following command to log into the tenant:

    ```sh
    az login --tenant <tenant-id>
    ```

1. Set the subscription to the one you want to use (you can use [az account list](https://learn.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest) to list available subscriptions):


    ```sh
    export AZURE_SUBSCRIPTION_ID="<your-subscription-id>"
    ```

    ```sh
    az account set --subscription $AZURE_SUBSCRIPTION_ID
    ```

1. Azure Developer CLI (azd) has its own authentication context. Run the following command to authenticate to Azure:

    ```sh
    azd auth login
    ```

    If you have multiple tenants, you can use the following command to log into the tenant:

    ```sh
    azd auth login --tenant-id <tenant-id>
    ```

### 2. Provision the app

1. Create a new AZD environment to store your deployment configuration values:

    ```sh
    azd env new <pick_a_name>
    ```

1. Set the default subscription for the azd context:

    ```sh
    azd env set AZURE_SUBSCRIPTION_ID $AZURE_SUBSCRIPTION_ID
    ```

1. To create the prod deployment:

    ```pwsh
    azd env set ENVIRONMENT prod
    ```

1. Production is a multi-region deployment. Choose an Azure region for the primary deployment (Run [az account list-locations --query '[].{Location: name}'](https://learn.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest) to see a list of locations):

    ```pwsh
    azd env set AZURE_LOCATION <pick_a_region>
    ```

    *You want to make sure the region has availability zones. Azure Database for PostgreSQL - Flexible Server [zone-redundant high availability](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-high-availability) requires availability zones.*

1. Choose an Azure region for the secondary deployment:

    ```pwsh
    azd env set AZURE_SECONDARY_LOCATION <pick_a_region>
    ```

    *We encourage readers to choose paired regions for multi-regional web apps. Paired regions typically offer low network latency, data residency in the same geography, and sequential updating. Read [Azure paired regions](https://learn.microsoft.com/en-us/azure/reliability/cross-region-replication-azure#azure-paired-regions) to learn more about these regions.*

1. Optional: Set the App Registration Service Management Reference:

    ```shell
    azd env set AZURE_SERVICE_MANAGEMENT_REFERENCE <service_management_reference>
    ```

1. Run the following command to create the Azure resources (about 45-minutes to provision):

    ```pwsh
    azd provision
    ```

    When successful the output of the deployment will be displayed in the terminal.

    ```sh
      Outputs:
      
      bastion_host_name = "vnet-bast-nickcontosocams-prod"
      frontdoor_url = "https://fd-nickcontosocams-prod-facscqd0a2gqf2eh.z02.azurefd.net"
      hub_resource_group = "rg-nickcontosocams-hub-prod"
      jumpbox_resource_id = "/subscriptions/1234/resourceGroups/rg-nickcontosocams-hub-prod/providers/Microsoft.Compute/virtualMachines/vm-jumpbox"
      primary_app_service_name = "app-nickcontosocams-eastus-prod"
      primary_spoke_resource_group = "rg-nickcontosocams-spoke-prod"
      secondary_app_service_name = "app-nickcontosocams-centralus-prod"
      secondary_spoke_resource_group = "rg-nickcontosocams-spoke2-prod"
    ```

    **These values are available to you by running `azd env get-values`.**

### 3. Set up the deployment environment

In order to deploy the application, you need to set up the deployment environment. This includes running the script `./scripts/setup-deployment-env.sh` in order to export environment variables used in subsequent steps.

1. Run the following command to set up the deployment environment:

    ```shell
    ./scripts/setup-deployment-env.sh
    ```

    This script will create the `deployment-env` file in the root of the project.

1. Source the environment variables:

    ```shell
    source deployment-env
    ```

    This will make the environment variables available in the current terminal session.

### 4. Configure App Config

1. Populate the `terraform.tfvars` file in the `infra/terraform-appconfig` folder with the following values:

    * primary_app_config_id
    * secondary_app_config_id
    * primary_app_config_keys
    * secondary_app_config_keys

    ```shell
    ./scripts/setup-appconfig-tfvars.sh 
    ```

### 5. Build Contoso Fiber CAMS

1. Run the following command to build the Contoso Fiber application:

    ```shell
    ./mvnw clean install
    ```

    This will create the jar file `cams.jar` in the `apps/contoso-fiber/target/` directory and `email-processor.jar` in the `apps/email-processor/target/` directory. The `cams.jar` will be used to deploy the application to Azure App Service. The `email-processor.jar` file will be included in a Docker image and uploaded to Azure Container Registry.

### 6. Build the Email Processor Docker image

1. Build the docker image

    ```shell
    docker build --platform linux/amd64 -f apps/email-processor/Dockerfile -t $TARGET_EMAIL_PROCESSOR_IMAGE ./apps/email-processor/
    ```

1. Save the docker image to a file

    ```shell   
    docker save -o $TARGET_EMAIL_PROCESSOR_IMAGE_FILE $TARGET_EMAIL_PROCESSOR_IMAGE
    ```

### 7. Upload the code to the jump box

1. Start a *new* terminal in the dev container

1. Run the following to set the environment variables for the bastion tunnel:

    ```sh
    source deployment-env
    ```

1. Ensure the following environment variables are set:

    ```sh
    echo $bastion_host_name
    echo $hub_resource_group
    echo $jumpbox_resource_id
    ```

1. We use the [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) to create a bastion tunnel that allows us to connect to the jump box. Run the following command to create a bastion tunnel to the jump box:

    ```sh
    az network bastion tunnel --name $bastion_host_name --resource-group $hub_resource_group --target-resource-id $jumpbox_resource_id --resource-port 22 --port 50022
    ```

    > **NOTE**
    >
    > Now that the tunnel is open, change back to use the original terminal session to deploy the code.

1. Install the SSH extension for Azure CLI:

    ```shell
    az extension add --name ssh
    ```

1. Obtain an SSH key from entra:
    
    ```shell
    az ssh config --ip 127.0.0.1 -f ./ssh-config
    ```

1. From the teminal, upload the `terraform-appconfig` folder

    ```shell
    rsync -av -e "ssh -F ./ssh-config -p 50022" infra/terraform-appconfig/ 127.0.0.1:~/terraform-appconfig
    ```

1. From the terminal, use the following command to upload CAMS to the jump box. 

    ```shell
    rsync -av -e "ssh -F ./ssh-config -p 50022" apps/contoso-fiber/target/cams.jar 127.0.0.1:~/cams.jar
    ```

1. From the terminal, use the following command to upload the email processor docker image to the jump box. 

    ```shell
    rsync -av -e "ssh -F ./ssh-config -p 50022" $TARGET_EMAIL_PROCESSOR_IMAGE_FILE 127.0.0.1:~/$TARGET_EMAIL_PROCESSOR_IMAGE_FILE
    ```

1. From the terminal, use the following command to upload the deployment environment file. 

    ```shell
    rsync -av -e "ssh -F ./ssh-config -p 50022" deployment-env 127.0.0.1:~/deployment-env
    ```

### 8. Log in to Azure from the jump box

1. Run the following command to start a shell session on the jump box:

    ```shell
    az ssh vm --ip 127.0.0.1 --port 50022
    ```

1. Run the following command to log in to Azure from the 1. Login into Azure using:

    ```shell
    az login --use-device-code
    ```

    If you have multiple tenants, you can use the following command to log into the tenant:

    ```shell
    az login --tenant <tenant-id> --use-device-code
    ```

1. Set the subscription id:

    ```shell
    az account set --subscription <subscription_id>
    ```

1. Source the deployment environment file:

    ```shell
    source deployment-env
    ```

    This will make the environment variables available in the current terminal session.

### 9. Create the App Config keys

1. Apply Terraform plan

    ```shell
    cd ~/terraform-appconfig
    ```

    ```bash
    terraform init
    terraform plan -out tfplan
    terraform apply tfplan
    ```

1. Verify that the keys were created.

    ```shell
    az appconfig kv list -n $primary_app_config_name --auth-mode login

    az appconfig kv list -n $secondary_app_config_name --auth-mode login
    ```

1. Change to the home directory

    ```shell
    cd
    ```

### 10. Configure Microsoft Entra authentication with Azure Database for PostgreSQL - Flexible Server

We will now configure the Contoso Fiber application to use Microsoft Entra authentication with Azure Database for PostgreSQL - Flexible Server. For more information, see [Tutorial: Create a passwordless connection to a database service via Service Connector](https://learn.microsoft.com/azure/service-connector/tutorial-passwordless?tabs=user%2Cjava%2Csql-me-id-dotnet%2Cappservice&pivots=postgresql)

1. Run the following command to install the serviceconnector-passwordless extension:

    ```
    az extension add --name serviceconnector-passwordless --upgrade
    ```

3. Run the following commands to configure the application:

    ```
    az webapp connection create postgres-flexible \
        --source-id $primary_app_service_id \
        --target-id $primary_database_id \
        --client-type springBoot \
        --system-identity
    ```

### 11. Deploy code from the jump box

1. Deploy the application to the primary region using:

    ```shell
    az webapp deploy --resource-group $primary_spoke_resource_group --name $primary_app_service_name --src-path cams.jar --type jar
    ```

1. Deploy the application to the secondary region using:

    ```shell
    az webapp deploy --resource-group $secondary_spoke_resource_group --name $secondary_app_service_name --src-path cams.jar --type jar --restart false --async true
    ```

    The `--restart false` flag is used to prevent the app from restarting after deployment. This is because the app is not yet configured to use the database as the secondary region is on stand by.

    > **WARNING**
    >
    > In some scenarios, the DNS entries for resources secured with Private Endpoint may have been cached incorrectly. It can take up to 10-minutes for the DNS cache to expire.

### 12. Deploy the email processor Docker image to Azure Container Registry

1. Add your user to the docker group

    ```shell
    sudo usermod -aG docker $(id -u -n)
    ```

1. Restart the ssh connection to pick up the new group membership

    ```shell
    exit

    az ssh vm --ip 127.0.0.1 --port 50022
    ```

1. Set the environment variables

    ```shell
    source deployment-env
    ```

1. Load the docker image.

    ```shell
    docker image load --input $TARGET_EMAIL_PROCESSOR_IMAGE_FILE
    ```

1. Verify the image was loaded.

    ```shell
    docker images
    ```

    You should see the image in the list of images.

    ```shell
    REPOSITORY                        TAG       IMAGE ID       CREATED       SIZE
    modern-java-web/email-processor                              1.0.0     475b1e60e832   25 hours ago   530MB
    ```

1. Tag the image.

    ```shell
    email_processor_image=$AZURE_CONTAINER_REGISTRY_ENDPOINT/$TARGET_EMAIL_PROCESSOR_IMAGE
    
    docker tag $TARGET_EMAIL_PROCESSOR_IMAGE $email_processor_image
    ```

1. Verify the image was tagged.

    ```
    docker images
    ```
    
    You should see the image in the list of images.

    ```shell
    REPOSITORY                                                   TAG       IMAGE ID       CREATED        SIZE
    crnikod1mwaprod.azurecr.io/modern-java-web/email-processor   1.0.0     475b1e60e832   25 hours ago   530MB
    modern-java-web/email-processor                              1.0.0     475b1e60e832   25 hours ago   530MB
    ```

1. Log into ACR

    ```shell
    az acr login -n $acr_name
    ```

1. Push the image to ACR

    ```shell
    docker push $email_processor_image
    ```

1. Update the container app with the email processor image

    ```shell
    az containerapp update -n email-processor -g $primary_spoke_resource_group --image $email_processor_image

    az containerapp update -n email-processor -g $secondary_spoke_resource_group --image $email_processor_image
    ```

1. Exit the jumpbox using:

    ```shell
    exit
    ```
1. Close the tunnel in the SEPARATE terminal using:

    ```shell
    CTRL+C
    ```

### 13. View the APP

1. Navigate to the Front Door URL in a browser to view the Contoso Fiber CAMS application.

    > You can learn more about the web app by reading the [Pattern Simulations](demo.md) documentation.

To get the Front Door URL, run the following command from your local terminal:

```shell
azd env get-values --output json | jq -r .frontdoor_url
```

### 14. Teardown

1. When you are done you can cleanup all the resources using:

    ```shell
    azd down --force --purge
    ```
