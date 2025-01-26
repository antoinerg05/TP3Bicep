@allowed([
    'canadaeast'
    'canadacentral'
])
param location string
param storageName string
param storageSku string = 'Standard_ZRS'

resource storage 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageName
  kind: 'StorageV2'
  location: location
  sku: {
    name: storageSku
  }
  properties: {
    
  }
}

resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2023-05-01' = {
  name: 'default'
  parent: storage
}

resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-05-01' = {
  name: 'queuedecouvert'
  parent: queueService
}

