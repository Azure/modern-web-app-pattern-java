# Modern Java Web App Patterns

## Introduction

This repository contains a collection of patterns and best practices for building modern Java web applications. The patterns are designed to be used with the [Spring Framework](https://spring.io/) and [Azure](https://azure.microsoft.com/), but can be adapted to other frameworks and cloud providers.


## Prerequisites

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Azure Dev CLI](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd?tabs=winget-windows%2Cbrew-mac%2Cscript-linux&pivots=os-mac)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [jq](https://stedolan.github.io/jq/download/)
- [Java 17](https://adoptopenjdk.net/)
- [Maven 3.9.1](https://maven.apache.org/download.cgi)
- [Protoc](https://grpc.io/docs/protoc-installation/)

## Login to Azure

Before deploying, you must be authenticated to Azure and have the appropriate subscription selected. Run the following command to authenticate:

```shell
az login
```

If you have multiple tenants, you can use the following command to log into the tenant:

```shell
az login --tenant <tenant-id>
```

Set the subscription to the one you want to use (you can use [az account list](https://learn.microsoft.com/en-us/cli/azure/account?view=azure-cli-latest#az-account-list) to list available subscriptions):

```shell
export AZURE_SUBSCRIPTION_ID="<your-subscription-id>"
```

```pwsh
az account set --subscription $AZURE_SUBSCRIPTION_ID
```

Use the next command to login with the Azure Dev CLI (AZD) tool:

```pwsh
azd auth login
```

If you have multiple tenants, you can use the following command to log into the tenant:

```pwsh
azd auth login --tenant-id <tenant-id>
```

## Create a new environment

Next we provide the AZD tool with variables that it uses to create the deployment. The first thing we initialize is the AZD environment with a name.

The environment name should be less than 18 characters and must be comprised of lower-case, numeric, and dash characters (for example, `contosowebapp`).  The environment name is used for resource group naming and specific resource naming.

```shell
azd env new <pick_a_name>
```

Select the subscription that will be used for the deployment:

```shell
azd env set AZURE_SUBSCRIPTION_ID $AZURE_SUBSCRIPTION_ID
```

Set the Azure region to be used:

```shell
azd env set AZURE_LOCATION <pick_a_region>
```

Optional: Set the App Registration Service management reference:

```shell
azd env set AZURE_SERVICE_MANAGEMENT_REFERENCE <service_management_reference>
```

## Build the applications

Run the following command to build the applications:

```shell
./mvnw clean install
```

## Create the Azure resources and deploy the code

Run the following command to create the Azure resources and deploy the code (about 15-minutes to complete):

```shell
azd up
```

## Tear down the deployment

Run the following command to tear down the deployment:

```
azd down --purge --force
```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
