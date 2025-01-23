param location string
param sqlServerName string
param sqlAdminUser string
@secure()
param sqlAdminPassword string
param sqlDbMvcName string
param sqlDbApiName string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: sqlAdminUser
    administratorLoginPassword: sqlAdminPassword
  }
}

resource sqlElasticPool 'Microsoft.Sql/servers/elasticPools@2022-05-01-preview' = {
  parent: sqlServer
  name: 'pool'
  location: location
sku: {
    name: 'StandardPool'
    tier: 'Standard'
    capacity: 300
  }
  properties: {
    perDatabaseSettings: {
      minCapacity: 50
      maxCapacity: 100
    }
  }
}

resource sqlDbMvc 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDbMvcName
  location: location
  properties: {
    elasticPoolId: sqlElasticPool.id
  }
    sku: {
    name: 'ElasticPool'
    tier: 'Standard'
    capacity: 0
  }
}

resource sqlDbApi 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDbApiName
  location: location
  properties: {
    elasticPoolId: sqlElasticPool.id
  }
    sku: {
    name: 'ElasticPool'
    tier: 'Standard'
    capacity: 0
  }
}
