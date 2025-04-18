targetScope = 'resourceGroup'

// Parameters
@description('Required. Azure location to which the resources are to be deployed')
param location string

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('Required. The naming module')
param naming object

var resourceNames = {
  keyVault: naming.keyVault.nameUnique
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: resourceNames.keyVault
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enabledForTemplateDeployment: true // ARM is permitted to retrieve secrets from the key vault. 
    accessPolicies: []
    enableSoftDelete: false
  }
}

// Outputs
output keyVaultName string = keyVault.name
