# Pattern Simulations

You can test and configure the code-level design patterns introduced in this implementation: strangler fig, queue-based load leveling and competing consumers, and distributed tracing. The following paragraphs detail steps to test these code-level design patterns.

As an evolution of the Reliable Web App (RWA), the Modern Web App (MWA) reference sample also includes design patterns that were showcased in RWA: retry, circuit-breaker, and cache-aside. For more information on these patterns and how to test them (both in RWA and MWA), see [Reliable Web App Pattern Simulations](https://github.com/Azure/reliable-web-app-pattern-java/blob/main/demo.md).

## Strangler Fig Pattern

Read the [Strangler Fig Pattern](./docs/SranglerFig.md) documentation.

After you deploy CAMS using `azd up`, the application is configured to use the new email service. The default value for `CONTOSO_SUPPORT_GUIDE_REQUEST_SERVICE` is set to `queue` for the App Service. Email requests go to the Azure Service Bus and are processed by the `email-processor` container app. This setting is defined in Azure App Configuration.

![edit-application-setting](./docs/assets/edit-application-setting.png)

To simulate the functionality, follow the steps below:

1. Open the CAMS application in a browser.
1. Upload a support guide by clicking on the `Support Guides` link in the navigation bar and click `Upload New Guide`. The guides are located in the `contoso-guides` directory.

    ![support-guids-location](./docs/assets/support-guides-location.png)

    ![upload-support-guide](./docs/assets/upload-support-guide.png)

1. Add an Account by clicking on the `Accounts` link in the navigation bar and click `Add Account`.

    ![Add Account](./docs/assets//add-account.png)

1. Click on the `New Support Case` button to create the Support Ticket.

    ![Add Account Form](./docs/assets/new-support-case.png)

1. Click on the support case and and then click the `Email Customer` button. You will see log message in the support case that the email was sent.

1. Navigate to the Container App in the Azure portal and click on the `Log Stream` link in the left navigation. 

    ![app-service-log-stream](./docs/assets/app-service-log-stream.png)

1. Navigate to the Container App in the Azure portal and click on the `Log Stream` link in the left navigation.

    ![container-app-log-stream](./docs/assets/container-app-log-stream.png)

    You will see the log messages from the `email-processor` container app and `CAMS`. 

    **Note**: It may take a few minutes for the message to be processed and the logs to appear.

1. Refresh the page and you will see that `CAMS` processed a response from the `email-processor`.

    ![send-email-queue](./docs/assets/send-email-queue.png)

1. Navigate to the Azure Service Bus in the Azure portal. You will see a spike in incoming messages.

    ![service-bus-incoming-messages](./docs/assets/service-bus-incoming-messages.png)

To see messages go though the old email service, change the value of the `CONTOSO_SUPPORT_GUIDE_REQUEST_SERVICE` key to `email` in Azure App Configuration. This is simulated by issuing a log message when the email functionality is called. 

![send-email-legacy](./docs/assets/send-email-legacy.png)

You will also see a log message from the email service that the email was sent in the Azure portal.

![send-email-legacy-log](./docs/assets/send-email-legacy-log.png)

## Distributed Tracing

You can also simulate the Strangler Fig Pattern and view the distributed tracing logs in Azure Monitor.

1. Navigate to the Azure Application Insights in the Azure portal and select the **Transaction Search** blade. Search for `New Message Received` to see the trace messages from the `email-processor` container app and the `CAMS` application running on App Service.

    ![transaction-search](./docs/assets/app-insights-transaction-search.png)

1. Click on the `New Message Received` transaction to see the details.

    ![transaction-details](./docs/assets/app-insights-transaction-details.png)

## Autoscaling Email Processor

The `email-processor` container app is configured to autoscale based on the number of messages in the Azure Service Bus. The `email-processor` container app scales out when the number of messages in the Service Bus exceeds a certain threshold.

![autoscale-settings](./docs/assets/email-processor-scaling-rule.png)

To simulate the autoscaling, follow the steps below:

1. Navigate to Azure App Configuration and change the `CONTOSO_SUPPORT_GUIDE_REQUEST_SERVICE` value to `demo-load`.

    ![edit-application-setting](./docs/assets/edit-application-setting-demo-load.png)

1. Restart the Web App in App Service.

    ![restart-app-service](./docs/assets/restart-app-service.png)

1. Send an email following the steps in the Strangler Fig Pattern section.

1. Navigate to the Azure Service Bus in the Azure portal. You will see a spike in incoming messages.

    ![service-bus-incoming-messages](./docs/assets/service-bus-request-queue-load-demo.png)

1. Navigate to the Container App in the Azure portal and click on the `Revisions and replicas` link under `Application` in the left navigation. Finally, click on the `Replicas` tab. You will see that the number of replicas has increased.

    ![container-app-revisions-replicas](./docs/assets/container-app-revisions-replicas.png)
