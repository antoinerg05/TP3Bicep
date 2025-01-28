@description('Nom de l’espace de noms du Service Bus')
param serviceBusNamespaceName string

@allowed([
  'canadacentral'
  'canadaeast'
])
@description('Région de déploiement (Canada Central ou Canada East)')
param location string

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
@description('Niveau tarifaire du Service Bus')
param sku string = 'Standard'

@description('Liste des files d’attente à créer avec leurs propriétés')
param queues array = [
  {
    name: 'decouverts'
    defaultMessageTimeToLive: 'P7D'
    maxSizeInMegabytes: 1024
  }
  {
    name: 'interets'
    defaultMessageTimeToLive: 'P1M'
    maxSizeInMegabytes: 512
  }
  {
    name: 'assurances'
    defaultMessageTimeToLive: 'PT12H'
    maxSizeInMegabytes: 512
  }
]

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2021-11-01' = {
  name: 'ns-${serviceBusNamespaceName}' 
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