set -x

# https://learn.microsoft.com/azure/service-connector/tutorial-passwordless?tabs=user%2Cdotnet%2Csql-me-id-dotnet%2Cappservice&pivots=postgresql#install-the-service-connector-passwordless-extension
az extension add --name serviceconnector-passwordless --upgrade
