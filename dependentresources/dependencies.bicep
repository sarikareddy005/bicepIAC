

@description('Required. The name of the server.')
param sqlservername string

@description(' The administrator username for the server. Required if no `administrators` object for AAD authentication is provided.')
param administratorLogin string = ''

@description('The administrator login password. Required if no `administrators` object for AAD authentication is provided.')
@secure()
param administratorLoginPassword string = ''


@description('Required. The name of the Storage Account to create.')
param storageAccountName string
param storageaccount_skuname string
param storageaccount_type string



@description('Required. The name of the Application Insights instance to create.')
param applicationInsightsName string

@description('Optional. The location to deploy resources to.')
param location string = resourceGroup().location

param applicationtype string

param managedidentityname string

param functionappplanname string
param serverOs string
param sku object
param zoneredundant bool

param functionappname string
param functionappos string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageaccount_skuname
  }
  kind: storageaccount_type
  properties: {
    publicNetworkAccess: 'Disabled'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: ''
  properties: {
    Application_Type: applicationtype
  }
}

resource identitymoduledeployment 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedidentityname
  location: location
}

resource server 'Microsoft.Sql/servers@2022-05-01-preview' = {
  location: location
  name: sqlservername
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    publicNetworkAccess: 'Disabled'
    version: '12.0'
  }
}

resource database 'Microsoft.Sql/servers/databases@2022-02-01-preview' = {
  name: '${sqlservername}-sqldb'
  location: location
  sku: {
    name: 'Basic'
    size: 'Basic'
    tier: 'Basic'
  }
  parent: server
}


resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: functionappplanname
  kind: serverOs
  location: location
  sku: sku
  properties: {
    zoneRedundant: zoneredundant
  }
}


resource functionapp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionappname
  kind: functionappos
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}




output storageAccountResourceId string = storageAccount.id
output applicationInsightsconnstring string = applicationInsights.properties.ConnectionString
output sqlserverResourceId string = server.id
output identityid string = identitymoduledeployment.id
output principalId string = identitymoduledeployment.properties.principalId
output serviceplanid string = appServicePlan.id
output functionappid string = functionapp.id
output databasename string = database.name

