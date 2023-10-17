param functionapp_name string
param functionapp_kind string
param storageAccountId string
param applicationinsightsconnectionstring string
param sqlservername string



resource functionappdeploy 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functionapp_name
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = if (!empty(storageAccountId)) {
  name: last(split(storageAccountId, '/'))
  scope: resourceGroup(split(storageAccountId, '/')[2], split(storageAccountId, '/')[4])
}

resource appSettings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  kind: functionapp_kind
  parent: functionappdeploy
  properties: {
    applicationinsightsconnectionstring: applicationinsightsconnectionstring
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};'
    sqlserverconnectionstring: 'Server=${sqlservername};Database=${'${sqlservername}-sqldb'};Trusted_Connection=True;'
  }
  }



