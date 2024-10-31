# Calculating Solution Service Level Agreement

The requirement for the Contoso Fiber CAMS application is that the combined service level agreement for all components in the hot path is greater than 99.9%.  The components in the hot path comprise of any service that is used in fulfilling a web request from a user.  

## Development

With a development environment, network isolation is not used.  The following services are considered:

| Service                        | Azure SLA |
|:-------------------------------|----------:|
| Azure Front Door               | 99.990%   |
| Entra ID                       | 99.990%   |
| Azure App Service              | 99.950%   |
| Azure Container Apps           | 99.950%   |
| Azure Container Registry       | 99.900%   |
| Azure Cache for Redis          | 99.900%   |
| Azure Postgres Flexible Server | 99.990%   |
| Azure Storage                  | 99.900%   |
| Azure Key Vault                | 99.990%   |
| App Configuration              | 99.900%   |
| Azure Service Bus              | 99.900%   |
| **Combined SLA**               | **99.362%** |

## Production - Single Region

When operating in production, network isolation is used.  We do not consider the availability of the hub resources or VNET peering.

| Service                   | Azure SLA   |
|:--------------------------|------------:|
| Azure Front Door          | 99.9900%    |
| Front Door Private Link   | 99.9900%    |
| Entra ID                  | 99.9900%    |
| Private DNS Zone          | 100.000%    |
| Azure Key Vault           | 99.9900%    |
| Key Vault Private Link    | 99.9900%    |
| Azure Container Registry* | 99.9999%    |
| **Combined global SLO**   | **99.9499%** |

* Note that the Azure Container Registry is deployed in two regions which allows its usual 99.9% SLA to increase to 99.9999% in total. For more information, see [Azure Container Registry Geo-replication](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication#considerations-for-using-a-geo-replicated-registry).

| Service               | Azure SLA |
|:----------------------|----------:|
| Azure App Service     | 99.950%   |
| - Private Link        | 99.990%   |
| Azure Container App   | 99.950%   |
| - Private Link        | 99.990%   |
| Azure Cache for Redis | 99.900%   |
| - Private Link        | 99.990%   |
|Azure Postgres Flexible Server | 99.990%   |
| - Private Link        | 99.990%   |
| Azure Storage         | 99.900%   |
| - Private Link        | 99.990%   |
| App Configuration     | 99.900%   |
| - Private Link        | 99.990%   |
| Azure Service Bus     | 99.900%   |
| **Combined regional SLO**    | **99.4215%** |

### Total production SLO

Because there are two redundant regions, the *total* regional SLO for the two regions combined is calculated as `1 - (1 - SLO)^2` where SLO is the SLO for a single regional spoke deployment. This gives us a total combined regional service SLO of **99.9967%**.

This total regional SLO is combined with the global SLO to give the total SLO for the production environment: **99.9467%**.

By having redundant resources in two regions, the total SLO for the production environment (99.9467%) exceeds the requirement of 99.9%.

For more information on how to calculate effective SLO, please refer to [the Well Architected Framework](https://learn.microsoft.com/azure/well-architected/reliability/metrics).