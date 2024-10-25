# Modernization Journey of Contoso Fiber's CAMS Web App

After migrating their Customer Account Management System (CAMS) to Azure, Contoso Fiber achieved their initial goals: a 99.9% SLO, optimized costs, and expanded reach. However, they recognized that leveraging Azure's cloud-native services would further improve agility, reliability, and scalability

## Modern Web App pattern for Java
Building on the prior [Reliable Web App pattern for Java](https://aka.ms/eap/rwa/java), which re-platformed CAMS in Azure with minimal code changes, Contoso now focuses on a Modern Web App Pattern to better utilize cloud-native capabilities. This phase involves:

- Refactoring the Monolith: By using the strangler-fig pattern, Contoso is gradually transforming the monolithic CAMS into modular components, enhancing scalability.
- Applying Queue-Based Load Leveling: This pattern optimizes performance by buffering external dependencies like email services, reducing load peaks.
- Improving Security and Reliability: Isolating services allows Contoso to better secure components and contain any potential failures.

This modernization lays a cloud-native foundation for CAMS, positioning Contoso Fiber for sustainable growth and adaptability.

## New services

* **Azure Container Apps** - The Modern Web App pattern reference sample uses Azure Container Apps to host a new email processing service that was separated from the web API as part of applying the [Strangler Fig pattern](https://learn.microsoft.com/azure/architecture/patterns/strangler-fig). Azure Container Apps is a fully managed serverless platform for running containerized apps. The reference sample uses Azure Container Apps because it provides managed container orchestration with support for automatic scale-in and scale-out based on a wide variety of rules using [KEDA](https://keda.sh/docs/2.13/) scalers. This allows the email processing service to automatically scale to zero when there is no work to be done and automatically scale up, as needed, based on the number of messages in the Service Bus queue.

* **Azure Container Registry** - Because the Modern Web App pattern reference sample uses Azure Container Apps, it also uses Azure Container Registry to store the container images for the email processing service. Azure Container Registry allows you to build, store, and manage container images and artifacts in a private registry for all types of container deployments. Azure Container Registry supports the reference sample's SLO goals by being highly available thanks to its [geo-replication](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication#configure-geo-replication) feature.

* **Azure Service Bus** - The Modern Web App pattern reference sample uses Azure Service Bus to enable message-based communication between the CAMS Application and the new email processing service. Using message-based communication allows improved reliability and performance by decoupling the CAMS application from the email processing service. Applying a [Queue-Based Load Leveling pattern](https://learn.microsoft.com/azure/architecture/patterns/queue-based-load-leveling) means that neither the CAMS application nor the email processing service will be affected by large numbers of email requests. The reference sample uses Azure Service Bus because it provides a fully managed, reliable, and secure messaging service that supports the reference sample's SLO goals.

* **Azure App Configuration Feature Manager** - The Modern Web App pattern uses Azure App Configuration to store the CAMS application settings. Azure App Configuration is a managed service that provides a central place to manage application settings and feature flags.
