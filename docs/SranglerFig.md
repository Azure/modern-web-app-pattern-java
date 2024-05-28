# Strangler Fig Pattern

The Strangler Fig Pattern is a software development pattern that is used to incrementally migrate a legacy system to a new system. The pattern is named after the strangler fig tree, which is a plant that grows on another tree and slowly strangles it. The pattern is used to avoid the risks associated with a complete system rewrite by allowing the new system to grow around the old system and gradually take over its functionality.

The original Contoso Fiber CAMS application has the capability of sending emails to customers with support guides. The application uses a blocking call to legacy email service. CAMS has grown in usage and the email functionality has been identified as bottleneck. The goal is to migrate the email functionality to a new service without disrupting the existing application.

Azure offers many services that can be used to build a new email service. The new email service is built using a combination of Azure Service Bus and Azure Container Apps. 

The Strangler Fig Pattern is a good fit for this scenario. The new email service will be developed and deployed alongside the existing email service. The new service will be integrated with the existing application and gradually take over the email functionality. Once the new service is fully operational, the old service can be decommissioned.

The Strangler Fig Pattern is implemented in the following steps:

1. **Identify the functionality to be migrated**: The first step is to identify the functionality that needs to be migrated. In this case, the email functionality of the Contoso Fiber CAMS application needs to be migrated to a new service.

The email functionality is implemented (here)[https://github.com/Azure/modern-web-app-pattern-java/blob/main/apps/contoso-fiber/src/main/java/com/contoso/cams/services/SupportGuideEmailSender.java]

2. **Develop the new service**: The next step is to develop the new service that will replace the existing functionality. The new service should be designed to be compatible with the existing application and should provide the same functionality.

The new email service is implemented (here)[https://github.com/Azure/modern-web-app-pattern-java/blob/main/apps/email-processor/src/main/java/com/contoso/cams/emailprocessor/EmailProcessor.java]

3. **Deploy the new service**: The new service is deployed alongside the existing application. The new service should be integrated with the existing application so that it can gradually take over the email functionality.

4. **Gradually migrate functionality**: The email functionality is gradually migrated from the old service to the new service. This can be done by routing a percentage of the email requests to the new service and gradually increasing the percentage over time.

Change the `CONTOSO_SUPPORT_GUIDE_REQUEST_SERVICE` environment variable from `email` to `queue` to migrate the email functionality to the new email service that's integrated with Azure Service Bus.

![request-service-email-setting](assets/request-service-email-setting.png)

![request-service-queue-setting](assets/request-service-queue-setting.png)

5. **Decommission the old service**: Once the new service is fully operational and all email functionality has been migrated, the old service can be decommissioned.

## Additional Resources

[Strangler Fig Pattern](https://docs.microsoft.com/en-us/azure/architecture/patterns/strangler-fig) documentation.
