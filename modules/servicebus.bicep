@description('Nom du namespace du Service Bus')
param serviceBusNamespaceName string

@description('Emplacement pour le déploiement (Canada Central ou Canada East)')
@allowed([
  'canadacentral'
  'canadaeast'
])
param location string

@description('Niveau tarifaire du Service Bus')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param sku string = 'Standard'

@description('Liste des files d’attente à créer')
param queues array

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: serviceBusNamespaceName
  location: location
  sku: {
    name: sku
    tier: sku
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Enabled'
  }
}

resource queuesResources 'Microsoft.ServiceBus/namespaces/queues@2021-11-01' = [for queue in queues: {
  name: '${serviceBusNamespace.name}/${queue.name}'
  properties: {
    defaultMessageTimeToLive: queue.defaultMessageTimeToLive
    maxSizeInMegabytes: queue.maxSizeInMegabytes
    enablePartitioning: false
  }
}]
