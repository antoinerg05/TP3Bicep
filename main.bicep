@allowed([
  'dev'
  'production'
])
param environmentType string = 'dev'
param location string = 'canadacentral'
param sqlAdminUser string = 'adminuser'
@secure()
param sqlAdminPassword string


param appPrefixs array = [
'webapp-tp2-bt-mvc'
'webapp-tp2-api'
]

param servicePlans array = [
  {
    name: 'sp-tp2-bt-mvc'
    appServices: [
        {
            name: 'webapp-tp2-bt-mvc'
            MiseAEchelle: 'Auto'
        }
        {
            name: 'webapp-tp2-api-calcul-int'
             MiseAEchelle: 'Non'
        }
    ]
  }
  {
    name: 'sp-tp2-api'
    appServices: [
        {
            name: 'webapp-tp2-api-assurance'
            MiseAEchelle: 'Non'
        }
        {
            name: 'webapp-tp2-api-carte-credit'
            MiseAEchelle : 'Manuel'
        }
    ]
  }
]


// Noms des ressources
var sqlServerName = 'sql-tp2-server'
var sqlDbMvcName = 'db-tp2-bt-mvc'
var sqlDbApiName = 'db-tp2-api'
var storageAccountName = 'sttp2storage'

// D�terminer le niveau de mise � l��chelle
var MiseAEchelle = (environmentType == 'prod') ? 'Auto' : 'Non'

// Module App Service
module appService './modules/appservice.bicep'  = [for (servicePlan, index) in servicePlans: {
  name: '${index}-deployAppService'
  params: {
    location: location
    appServicePlanName: servicePlan.name
    appServices: servicePlan.appservices
  }
}]

// Module SQL
module sql './modules/sql.bicep' = {
  name: 'deploySql'
  params: {
    location: location
    sqlServerName: sqlServerName
    sqlAdminUser: sqlAdminUser
    sqlAdminPassword: sqlAdminPassword
    sqlDbMvcName: sqlDbMvcName
    sqlDbApiName: sqlDbApiName
  }
}

// Module Storage
module storage './modules/storage.bicep' = {
  name: 'deployStorage'
  params: {
    location: location
    storageAccountName: storageAccountName
  }
}

// Sorties
//output appServicePlanMvc string = appServicePlanMvcName
//output appServicePlanApi string = appServicePlanApiName
//output mvcAppUrl string = appService.outputs.mvcAppUrl
//output apiAppUrl string = appService.outputs.apiAppUrl
//output sqlServer string = sqlServerName
//output sqlDbMvc string = sqlDbMvcName
//output sqlDbApi string = sqlDbApiName
//output storageAccount string = storageAccountName
//output storageContainerUrl string = storage.outputs.containerUrl
