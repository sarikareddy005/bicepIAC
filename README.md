 bicepIAC project is regarding the function app deployment
 Below is the deployment flow and the folder structure
 dependentresources folder consists of the resources required by the functionapp long with function app
 
 dependencies.bicep consists of the code for
 1. storage account
 2. SQL server and Database
 3. Managed identity
 4. application insights
 5. functionapp service plan
 6. functionapp

customroles.bicep consists of the code for custom role creation with required permissions

functionappsettings.bicep consists of the code for integrating storage account, sql server and application insights with the function app

resourcesdeployment.bicep is the template file which consists of the module that calls out all the resources in the dependencies.bicep, functionappsettings.bicep and customroles.bicep

resourcesdeployment.parameters.all.json file consists of the all the parameters that are required for the deployment.

deployment flow

when resourcesdeployment.bicep is run, the module in it calls out all the resources from the customroles.bicep, functionappsettings.bicep and dependencies.bicep and picks the parameters from the resourcesdeployment.parameters.all.json

azure monitoring : application insights is integrated.
azure security : public network access has been disabled

In progress : create a keyvault and store and use passwords whenever required.