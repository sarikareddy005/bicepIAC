targetScope = 'subscription'


@description('Name of  Resource Group under the chosen Subscription that all the resources will be deployed')
param resourceGroupName string



@description('location of  Resource Group under the chosen Subscription that all the resources will be deployed')
param location string = ''

param customrolename string

@description('Lifecycle of the environment (dev,stage, prod, etc.). Default is `dev`')
param env string = 'dev'

param uai string

@description('Default tags to add to resources')
var defaultTags = {
  env: env
  uai: uai
}

param functionappplan_name string
param functionappplan_sku object
param zoneredundant bool


param storageaccountname string
param applicationinsightsname string

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageaccount_skuname string

@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'FileStorage'
  'BlockBlobStorage'
])
param storageaccount_type string
param applicationtype string

param functionapp_name string
param functionapp_kind string




param managedidentityname string
param serveros string

@description('Required. The name of the server.')
param sqlservername string

@description(' The administrator username for the server. Required if no `administrators` object for AAD authentication is provided.')
param administratorlogin string = ''

@description('The administrator login password. Required if no `administrators` object for AAD authentication is provided.')
@secure()
param adminpassword string = ''

/*
module ResourceGroup '../../../../../ResourceModules/modules/Microsoft.Resources/resourceGroups/deploy.bicep' = {
  name: '${resourceGroupName}${uniqueString(deployment().name)}'
  scope: subscription(subscriptionId)
  params: {
    location: location
    name: resourceGroupName
    tags: defaultTags
    managedBy: managedBy
  }
}
*/

resource resourcegroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
  tags: defaultTags
}

module customroles 'dependentresources/customroles.bicep' = {
  name: '${uniqueString(customrolename, location)}-nestedDependencies'
  params: {
    customrolename: customrolename
  }
}


module nestedDependencies 'dependentresources/dependencies.bicep' = {
  name: '${uniqueString(location)}-nestedDependencies'
  scope: resourcegroup
  params:{
    storageAccountName: storageaccountname
    applicationInsightsName: applicationinsightsname
    location: location
    storageaccount_skuname: storageaccount_skuname
    storageaccount_type: storageaccount_type
    applicationtype: applicationtype
    managedidentityname: managedidentityname
    sqlservername: sqlservername
    administratorLogin: administratorlogin
    administratorLoginPassword: adminpassword
    functionappplanname: functionappplan_name
    sku: functionappplan_sku
    serverOs: serveros
    zoneredundant: zoneredundant
    functionappname: functionapp_name
    functionappos: functionapp_kind
  }
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceId('Microsoft.Authorization/roleDefinitions', customrolename), location)
  properties: {
    roleDefinitionId: customroles.outputs.customroleid
    principalId: nestedDependencies.outputs.principalId
  }
}

module functionappsettings 'dependentresources/functionappsettings.bicep' = {
  name: '${uniqueString(location)}-functionappsettings'
  scope: resourcegroup
  params: {
    functionapp_name: functionapp_name
    functionapp_kind: functionapp_kind
    applicationinsightsconnectionstring: nestedDependencies.outputs.applicationInsightsconnstring
    storageAccountId: nestedDependencies.outputs.storageAccountResourceId
    sqlservername: sqlservername
  }
}





