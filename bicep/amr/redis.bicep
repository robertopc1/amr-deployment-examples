targetScope = 'resourceGroup'

// Parameters
@description('Required. Azure location to which the resources are to be deployed')
param location string

@description('Optional. Deploy Active-Active')
param activeGeoReplicationEnabled bool = false

@description('Optional. Azure secondary location to which the resources are to be deployed')
param location2 string = ''

@description('Optional. The Azure Managed Redis sku.')
@allowed([
  'MemoryOptimized_M10'
  'MemoryOptimized_M20'
  'MemoryOptimized_M50'
  'MemoryOptimized_M100'
  'MemoryOptimized_M150'
  'MemoryOptimized_M250'
  'MemoryOptimized_M350'
  'MemoryOptimized_M500'
  'MemoryOptimized_M700'
  'MemoryOptimized_M1000'
  'MemoryOptimized_M1500'
  'MemoryOptimized_M2000'
  'Balanced_B0'
  'Balanced_B1'
  'Balanced_B3'
  'Balanced_B5'
  'Balanced_B10'
  'Balanced_B20'
  'Balanced_B50'
  'Balanced_B100'
  'Balanced_B150'
  'Balanced_B250'
  'Balanced_B350'
  'Balanced_B500'
  'Balanced_B700'
  'Balanced_B1000'
  'ComputeOptimized_X3'
  'ComputeOptimized_X5'
  'ComputeOptimized_X10'
  'ComputeOptimized_X20'
  'ComputeOptimized_X50'
  'ComputeOptimized_X100'
  'ComputeOptimized_X150'
  'ComputeOptimized_X250'
  'ComputeOptimized_X350'
  'ComputeOptimized_X500'
  'ComputeOptimized_X700'
  'FlashOptimized_A250'
  'FlashOptimized_A500'
  'FlashOptimized_A700'
  'FlashOptimized_A1000'
  'FlashOptimized_A1500'
  'FlashOptimized_A2000'
  'FlashOptimized_A4500'
])
param skuName string = 'MemoryOptimized_M10'

@description('Optional. The Azure Managed Enterprise clustering policy.')
@allowed([
  'EnterpriseCluster'
  'OSSCluster'
])
param clusteringPolicy string = 'EnterpriseCluster'

@description('Optional. The Azure Managed Redis eviction policy.')
@allowed([
  'AllKeysLFU'
  'AllKeysLRU'
  'AllKeysRandom'
  'NoEviction'
  'VolatileLFU'
  'VolatileLRU'
  'VolatileRandom'
  'VolatileTTL'
])
param evictionPolicy string = 'NoEviction'

@description('Optional. Persist data stored in Azure Managed Redis.')
@allowed([
   'Disabled'
   'RDB'
   'AOF'
])
param persistenceOption string = 'Disabled'

@description('Optional. The frequency at which data is written to disk.')
@allowed([
  '1s'
  'always'
])
param aofFrequency string = '1s'

@description('Optional. The frequency at which a snapshot of the database is created.')
@allowed([
  '12h'
  '1h'
  '6h'
])
param rdbFrequency string = '6h'

@description('Optional. The Azure Managed Redis module(s)')
@allowed([
  'RedisBloom'
  'RedisTimeSeries'
  'RedisJSON'
  'RediSearch'
])
param modulesEnabled array = []

@description('Optional. The tags to be assigned to the created resources.')
param tags object = {}

@description('Required. Enable High Availability')
param haOption bool = true

@description('Required. Workload name')
param workloadName string

@description('Required. Key Vault ')
param keyVaultName string

@description('Optional. Use Managed Identity for authentication. If false, key-based authentication will be used.')
param useManagedIdentity bool = true

@description('Required. the naming module')
param naming object

// Variables
var resourceNames = {
  redisLocation1Name: naming.redisCache.nameUnique
  redisLocation2Name: 'redis-${workloadName}-${location2}'
  redisDbName: 'default'
  redisGeoReplicationGroupName: 'gr-${workloadName}'
}

var rdbPersistence = persistenceOption == 'RDB' ? true : false
var aofPersistence = persistenceOption == 'AOF' ? true : false
var enableHA = haOption ? 'Enabled' : 'Disabled'

//Resources
resource redisCluster1 'Microsoft.Cache/redisEnterprise@2024-09-01-preview' = {
  name: resourceNames.redisLocation1Name
  location: location
  sku: {
    name: skuName
  }
  properties: {
    minimumTlsVersion: '1.2'
    highAvailability: enableHA
  }
  identity: useManagedIdentity ? {
    type: 'SystemAssigned'
  } : {
    type: 'None'
  }
  
  tags: tags
}

resource redisCluster1Db 'Microsoft.Cache/redisEnterprise/databases@2024-09-01-preview' = {
  name: resourceNames.redisDbName
  parent: redisCluster1
  properties: {
    accessKeysAuthentication: useManagedIdentity ? 'Disabled' : 'Enabled'
    clientProtocol:'Encrypted'
    port: 10000
    clusteringPolicy: clusteringPolicy
    evictionPolicy: evictionPolicy
    persistence: {
      aofEnabled: aofPersistence
      aofFrequency: aofPersistence ? aofFrequency : null
      rdbEnabled: rdbPersistence
      rdbFrequency: rdbPersistence ? rdbFrequency : null
    }
    modules: [for module in modulesEnabled: {
      name: module
    }]
    geoReplication: activeGeoReplicationEnabled ? {
       groupNickname: resourceNames.redisGeoReplicationGroupName 
       linkedDatabases: [
        {
          id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Cache/redisEnterprise/${resourceNames.redisLocation1Name}/databases/default'
        }
       ]
    } : null
  }
}

resource redisCluster2 'Microsoft.Cache/redisEnterprise@2024-09-01-preview' =  if(activeGeoReplicationEnabled) {
  name: resourceNames.redisLocation2Name
  location: location2
  dependsOn: [
    redisCluster1
  ]
  sku: {
    name: skuName
  }
  properties: {
    minimumTlsVersion: '1.2'
    highAvailability: enableHA
  }
  identity: useManagedIdentity ? {
    type: 'SystemAssigned'
  } : {
    type: 'None'
  }
  tags: tags
}

resource redisLocation2Db 'Microsoft.Cache/redisEnterprise/databases@2024-09-01-preview' = if(activeGeoReplicationEnabled) {
  name: resourceNames.redisDbName
  parent: redisCluster2
  properties: {
    accessKeysAuthentication: useManagedIdentity ? 'Disabled' : 'Enabled'
    clientProtocol:'Encrypted'
    port: 10000
    clusteringPolicy: clusteringPolicy
    evictionPolicy: evictionPolicy
    persistence: {
      aofEnabled: aofPersistence
      aofFrequency: aofPersistence ? aofFrequency : null
      rdbEnabled: rdbPersistence
      rdbFrequency: rdbPersistence ? rdbFrequency : null
    }
    modules: [for module in modulesEnabled: {
      name: module
    }]
    geoReplication: {
       groupNickname: resourceNames.redisGeoReplicationGroupName
       linkedDatabases: [
          {
            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Cache/redisEnterprise/${resourceNames.redisLocation1Name}/databases/default'
          }
          {
            id: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Cache/redisEnterprise/${resourceNames.redisLocation2Name}/databases/default'
          }
        ]       
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = if(!useManagedIdentity) {
  name: keyVaultName
}

resource redisPassword 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = if(!useManagedIdentity) {
  parent: keyVault
  name: 'redisPassword'  // The first part is KV's name
  properties: {
   value: '${listKeys(redisCluster1.id, redisCluster1.apiVersion).keys[0].value}'
  }
 }

//Output
output redisLocation1Name string = redisCluster1.name
output redisLocation1Id string = redisCluster1.id
output redisLocation1HostName string = redisCluster1.properties.hostName

output redisLocation2Name string = (redisCluster2 != null) ? redisCluster2.name : ''
output redisLocation2Id string  =  (redisCluster2 != null) ? redisCluster2.id : ''
output redisLocation2HostName string =  (redisCluster2 != null) ? redisCluster2.properties.hostName : ''


