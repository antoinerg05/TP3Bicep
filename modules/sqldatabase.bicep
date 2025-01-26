@allowed([
    'canadaeast'
    'canadacentral'
])
param location string
param sqlServerName string
param sqlAdminLogin string
@minLength(10)
@maxLength(20)
@secure()
param sqlAdminPassword string
param databaseNames array

param startIpAddress string
param endIpAddress string

param DTUmin int
param DTUmax int

resource sqlServer 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: 'srv-${sqlServerName}'
  location: location
  properties: {
    administratorLogin: sqlAdminLogin
    administratorLoginPassword: sqlAdminPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2024-05-01-preview' = [for database in databaseNames :{
  name: 'db-${database}'
  location: location
  parent: sqlServer
  properties: {
    elasticPoolId: elasticPool.id
  }
}]

resource elasticPool 'Microsoft.Sql/servers/elasticPools@2024-05-01-preview' = {
  name: 'pool-${sqlServerName}'
  parent: sqlServer
  location: location
  properties: {
    perDatabaseSettings: {
      minCapacity: DTUmin
      maxCapacity: DTUmax
    }
  }
  sku: {
    name: 'BasicPool'
    tier: 'Basic'
  }
}

resource sqlFirewallRule 'Microsoft.Sql/servers/firewallRules@2024-05-01-preview' = {
  name: 'PlageIps-${sqlServerName}'
  parent: sqlServer
  properties: {
    startIpAddress: startIpAddress
    endIpAddress: endIpAddress
  }
}
