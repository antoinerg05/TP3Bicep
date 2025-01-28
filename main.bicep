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

param storageName string
param env string

var apps = [
    {
        spName: 'tardi1'
        webApps: ['mvc-${env}', 'apiinteret-${env}']
        miseAEchelle: 'Auto'
    }
    {
        spName: 'tardi2'
        webApps: [ 'apiassurance-${env}', 'apicredit-${env}']
        miseAEchelle: 'Non'
    }
]

var skuMap = {
    Non: 'F1'
    Manuel: 'B1'
    Auto: 'S1'
}

var databaseNames = [ 'mvc', 'assurance', 'cartecredits']

module appService 'modules/appService.bicep' = [ for app in apps: {
    name: 'appService${app.spName}-${env}'
    params: {
        location: location
        spName:  '${app.spName}-${env}' 
        webAppNames: app.webApps
        spSku: skuMap[app.miseAEchelle]
    }
}]

module sqldatabase 'modules/sqldatabase.bicep' = {
    name: 'sqldatabase${sqlServerName}'
    params: {
        sqlServerName: '${sqlServerName}-${env}'
        databaseNames: databaseNames
        location: location
        sqlAdminLogin: sqlAdminLogin
        sqlAdminPassword: sqlAdminPassword
        DTUmin: 5
        DTUmax: 5
        startIpAddress: '0.0.0.0'
        endIpAddress: '255.255.255.255'
    }
}

module storageService 'modules/storage.bicep' = {
    name: 'storageService_${storageName}'
     params: {
         storageName: '${storageName}${env}'
          location: location
          storageSku: 'Standard_ZRS'
     }
}

var queues = [
  {
    name: 'decouverts-${env}'
    defaultMessageTimeToLive: 'P7D'
    maxSizeInMegabytes: 1024
  }
  {
    name: 'interets-${env}'
    defaultMessageTimeToLive: 'P1M'
    maxSizeInMegabytes: 512
  }
  {
    name: 'assurances-${env}'
    defaultMessageTimeToLive: 'PT12H'
    maxSizeInMegabytes: 512
  }
]

module serviceBus 'modules/servicebus.bicep' = {
    name: 'serviceBus-${env}'
     params: {
          serviceBusNamespaceName: 'sbServiceBus${env}'
          queues: queues
          location: location
     }
}