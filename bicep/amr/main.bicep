targetScope = 'subscription'

@description('Optional. Azure main location to which the resources are to be deployed -defaults to the location of the current deployment')
param location string = deployment().location

@description('Optional. Azure second location to which the resources are to be deployed - defaults to westus')
param location2 string = 'westus2'

@description('Optional. Deploy active active -defaults to false')
param activeGeoReplicationEnabled bool = false

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('Optional. Use managed identity on AMR')
param useManagedIdentity bool = true

@description('Optional. A numeric suffix (e.g. "001") to be appended on the naming generated for the resources. Defaults to empty.')
param numericSuffix string = ''

@description('Required. The name of the environmentName (e.g. "dev", "test", "prod", "preprod", "staging", "uat", "dr", "qa"). Up to 8 characters long.')
@maxLength(8)
param environmentName string = 'dev'

var workloadName = 'myapplication'

var defaultTags = union({
  workloadName: workloadName
  environment: environmentName
}, tags)


var resourceSuffix = '${workloadName}-${environmentName}-${location}'
var appResourceGroupName = 'rg-${resourceSuffix}'

var defaultSuffixes = [
  workloadName
  environmentName
  '**location**'
]

var namingSuffixes = empty(numericSuffix) ? defaultSuffixes : concat(defaultSuffixes, [
  numericSuffix
])

// Create resource groups
resource appResourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: appResourceGroupName
  location: location
  tags: defaultTags
}

module naming './shared/naming.module.bicep' = {
  scope: resourceGroup(appResourceGroup.name)
  name: 'namingModule-Deployment'  
  params: {
    location: location
    suffix: namingSuffixes
    uniqueLength: 6
  }
}

module kv 'keyvault.bicep' = {
  name: take('kv-${deployment().name}-deployment', 64)
  scope: resourceGroup(appResourceGroup.name)
  params: {
    location: location
    tags: defaultTags
    naming: naming.outputs.names
  }
}

//Create Redis resource
module redis 'redis.bicep' = {
  scope: resourceGroup(appResourceGroup.name)
  name: take('redis-${deployment().name}-deployment', 64)
  params: {
    keyVaultName: kv.outputs.keyVaultName
    location: location
    location2: location2
    activeGeoReplicationEnabled: activeGeoReplicationEnabled
    tags: defaultTags
    workloadName: workloadName
    useManagedIdentity: useManagedIdentity
    naming: naming.outputs.names
  }
}

output appResourceGroupName string = appResourceGroup.name
