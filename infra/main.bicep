targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

@description('Id of the user or app to assign application roles')
param principalId string

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

//invoke the resources.bicep file
module fdcdn './fdcdn.bicep' = {
  scope: rg
  name: 'resourcesDeployment'
  params: {
    location: location
    tags: tags
    environmentName: environmentName
    principalId: principalId

  }
}

output WEBAPP_SERVICE_NAME string = fdcdn.outputs.AppServiceName
output BLOB_BASE_IMAGE_URL string = fdcdn.outputs.BlobImageBaseUrl
output CDN_BASE_IMAGE_URL string = fdcdn.outputs.CDNImageBaseUrl
