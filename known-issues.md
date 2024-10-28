# Known issues
This document helps with troubleshooting and provides an introduction to the most requested features, gotchas, and questions.

## Deploying the app to the second region

The production deployment calls for the app to be deployed to two regions. The azure cli command `az webapp deploy` does not honor the `--restart false` flag. The app will fail to be restarted after deployment because the database is not yet configured to use the secondary region.

Below is the error that you may see after deploying the app to the second region:

![az webapp deploy error](./docs/assets/az-webapp-deploy-error-second-region.png)