param location string
param storageAccountName string

// Cr�ation du compte de stockage
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

// Cr�ation du service Blob (n�cessaire pour les conteneurs)
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  parent: storageAccount
  name: 'default'
}

// Cr�ation du conteneur Blob
resource storageContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  parent: blobService
  name: 'documents'
  properties: {
    publicAccess: 'None'
  }
}

// Cr�ation du service de file d�attente
resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2021-09-01' = {
  parent: storageAccount
  name: 'default'
}

// Cr�ation de la file d'attente
resource queue 'Microsoft.Storage/storageAccounts/queueServices/queues@2021-09-01' = {
  parent: queueService
  name: 'queuedecouvert'
}

// Sorties
output containerUrl string = '${storageAccount.properties.primaryEndpoints.blob}documents'
output queueUrl string = '${storageAccount.properties.primaryEndpoints.queue}queuedecouvert'
