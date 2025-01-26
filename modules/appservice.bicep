param spName string
@allowed([
    'canadaeast'
    'canadacentral'
])
param location string
param webAppNames array
param spSku string

resource servicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'sp-${spName}'
  location: location
  sku:{
    name: spSku
  }
  tags:{
    name: 'Application'
    value: spName
  }
}

resource webApp 'Microsoft.Web/sites@2024-04-01' = [for webAppName in webAppNames: {
  name: 'webapp-${webAppName}-${uniqueString(resourceGroup().id)}'
  location: location
  properties: {
    serverFarmId:servicePlan.id
  }
  tags:{
    name: 'Application'
    value: webAppName
  }
}]

resource stagingSlot 'Microsoft.Web/sites/slots@2024-04-01' = [for i in range(0, length(webAppNames)) : if(spSku == 'S1'){
  name: '${webApp[i].name}-staging'
  parent: webApp[i]
  location: location
  properties: {
      serverFarmId:servicePlan.id
  }
  tags:{
    name: 'Application'
    value: '${webApp[i].name}-staging'
  }
}]

resource scaling 'Microsoft.Insights/autoscalesettings@2022-10-01' =  if(spSku == 'S1') {
  name: '${servicePlan.name}-scale'
  location: location
  properties: {
    enabled: true
    targetResourceUri: servicePlan.id
    profiles: [
      {
        name: 'ConditionAugmentation'
        capacity:{
          minimum: '1'
          maximum: '4'
          default: '1'
        }
        rules: [
          {
            scaleAction: {
              type: 'ChangeCount'
              direction: 'Increase'
              cooldown: 'PT5M'
              value: '1'
            }
            metricTrigger: {
              metricName: 'CpuPercentage'
              operator: 'GreaterThan'
              timeAggregation: 'Average'
              threshold: 70
              metricResourceUri: servicePlan.id
              timeWindow: 'PT10M'
              timeGrain: 'PT1M'
              statistic: 'Average'
            }
          }
          {
            scaleAction: {
              type: 'ChangeCount'
              direction: 'Decrease'
              cooldown: 'PT5M'
              value: '1'
            }
            metricTrigger: {
              metricName: 'CpuPercentage'
              operator: 'LessThanOrEqual'
              timeAggregation: 'Average'
              threshold: 50
              metricResourceUri: servicePlan.id
              timeWindow: 'PT10M'
              timeGrain: 'PT1M'
              statistic: 'Average'
            }
          }
        ]
      }
    ]
  }
  tags:{
    name: 'Application'
    value: '${servicePlan.name}-scale'
  }
}
