targetScope = 'subscription'
param customrolename string




var role_perms = {
  properties: {
    roleName: 'NonameAccessRole'
    description: 'Noname Security Azure Integrations required permissions'
    permissions: [
      {
        actions: [
          '*/read'
          'Microsoft.Resources/subscriptions/*/read'
          'Microsoft.Resources/subscriptions/resourceGroups/*/read'
          'Microsoft.Resources/subscriptions/resourceGroups/write'
          'Microsoft.Resources/providers/*/read'
          'Microsoft.Resources/tags/*/read'
          'Microsoft.Resources/deployments/validate/action'
          'Microsoft.Resources/deployments/write'
          'Microsoft.Storage/storageAccounts/read'
          'Microsoft.Storage/storageAccounts/listkeys/action'
          'Microsoft.Storage/storageAccounts/blobServices/containers/read'
          'Microsoft.Storage/storageAccounts/write'
          'Microsoft.Storage/storageAccounts/delete'
          'Microsoft.Web/sites/*/read'
          'Microsoft.Web/sites/providers/Microsoft.Insights/*'
          'Microsoft.Web/sites/functions/*/read'
          'Microsoft.Web/sites/functions/write'
          'Microsoft.Web/sites/config/*'
          'Microsoft.Web/sites/config/list/action'
          'Microsoft.Web/sites/extensions/*'
          'Microsoft.Insights/components/*'
          'Microsoft.Insights/components/ApiKeys/*'
          'Microsoft.Insights/components/ApiKeys/action'
        ]
        notActions: []
        dataActions: []
        notDataActions: []
      }
    ]
  }
}
var role_properties = role_perms

resource customrole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid(customrolename, subscription().id)
  properties: {
    description: role_properties.properties.description
    roleName: customrolename
    permissions: role_properties.properties.permissions
    assignableScopes: [
      subscription().id
    ]
  }
}

output customroleid string = customrole.id
