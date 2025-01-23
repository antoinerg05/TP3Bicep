param location string
param appServicePlanName string
param appServices array

@allowed([
  'Non' // Pas de mise à l’échelle
  'Manuel' // Mise à l’échelle manuelle
  'Auto' // Mise à l’échelle automatique
])
param MiseAEchelle string = 'Non'

// Déterminer le SKU en fonction de MiseAEchelle
var skuName = (MiseAEchelle == 'Non') ? 'F1' : (MiseAEchelle == 'Manuel') ? 'B1' : 'S1'
var skuTier = (MiseAEchelle == 'Non') ? 'Free' : (MiseAEchelle == 'Manuel') ? 'Basic' : 'Standard'

// Plan de service pour MVC
resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
}
var uniqueSuffix = uniqueString(resourceGroup().id)

// Plan de service pour API
resource appServiceApp 'Microsoft.Web/sites@2021-02-01' = [for (appService, index) in appServices: {
  name: '${appService.name}-${uniqueSuffix}'
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    serverFarmId: appServicePlan.id
  }
}]


// Slots de staging (uniquement pour mise à l’échelle automatique)
/*resource mvcSlot 'Microsoft.Web/sites/slots@2021-02-01' = if (MiseAEchelle == 'Auto') {
  parent: appServiceApp1
  name: 'staging'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}

resource apiSlot 'Microsoft.Web/sites/slots@2021-02-01' = if (MiseAEchelle == 'Auto') {
  parent: appServiceApp2
  name: 'staging'
  location: location
  properties: {
    serverFarmId: appServicePlan.id
  }
}
*/
// Sorties
//output app1Url string = 'https://${appServiceApp1.properties.defaultHostName}'
//output app2Url string = 'https://${appServiceApp2.properties.defaultHostName}'
