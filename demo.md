# Pattern Simulations

## Strangler Fig Pattern

Read the [Strangler Fig Pattern](./docs/SranglerFig.md) documentation.

After you deploy CAMS using `azd up`, the application is configured to use the legacy email service. This is simulated by issuing a log message when the email functionality is called. To simulate the functionality, follow the steps below:

1. Open the CAMS application in a browser.
2. Add an Account by clicking on the `Accounts` link in the navigation bar.
