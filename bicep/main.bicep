param namePrefix string = 'fileupload'
param appId string
// param password string
param tenantId string

param location string = resourceGroup().location

var managedIdentityName = '${namePrefix}-mi'

var prefix = toLower(substring(namePrefix, 0, min(length(namePrefix), 8)))
var suffix = substring(uniqueString(resourceGroup().id), 0, 8)

var keyVaultName = '${prefix}-kv-${suffix}'
var storageAccountName = toLower('${prefix}sa${suffix}')
var storageAccountContainerName = toLower('${prefix}sac${suffix}')

@minLength(5)
@maxLength(50)
@description('Provide a globally unique name of your Azure Container Registry')
param acrName string = '${namePrefix}acr${uniqueString(resourceGroup().id)}'

module managedIdentityModule 'modules/managedIdentity.bicep' = {
  name: 'managedIdentityModule'
  params: {
    location: location
    managedIdentityName: managedIdentityName
  }
}

module keyVaultModule 'modules/keyvault.bicep' = {
  name: 'keyVaultModule'
  dependsOn: [
    managedIdentityModule
  ]
  params: {
    location: location
    keyVaultName: keyVaultName
    managedIdentityName: managedIdentityName
    appId: appId
  }
}

output kvName string = keyVaultModule.outputs.kvName

module storageAccountModule 'modules/storageAccounts.bicep' = {
  name: 'storageAccountModule'
  params: {
    location: location
    storageAccountName: storageAccountName
    storageAccountContainerName: storageAccountContainerName
    storageAccountType: 'Standard_LRS'
    appId: appId
  }
}

resource sa 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName
  dependsOn: [
    storageAccountModule
  ]
}
output saName string = sa.name

// Determine our connection string

var blobStorageConnectionString = 'DefaultEndpointsProtocol=https;EndpointSuffix=${environment().suffixes.storage};AccountName=${sa.name};AccountKey=${sa.listKeys().keys[0].value};BlobEndpoint=https://${sa.name}.blob.core.windows.net/;FileEndpoint=https://${sa.name}.file.core.windows.net/;QueueEndpoint=https://${sa.name}.queue.core.windows.net/;TableEndpoint=https://${sa.name}.table.core.windows.net/'
// DefaultEndpointsProtocol=https;AccountName=${sa.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${sa.listKeys().keys[0].value}
// DefaultEndpointsProtocol=https;EndpointSuffix=${environment().suffixes.storage};AccountName=${sa.name};AccountKey=${sa.listKeys().keys[0].value}


module keyVaultSecretModule 'modules/keyvaultsecret.bicep' = {
  name: 'keyVaultSecretModule'
  params: {
    keyVaultName: keyVaultName
    secretName: '${storageAccountName}-conn-str'
    secretValue: blobStorageConnectionString
  }
}

module acrModule 'modules/acr.bicep' = {
  name: 'acrModule'
  params: {
    location: location
    acrName: acrName
  }
}

output acrLoginServer string = acrModule.outputs.acrLoginServer
output acrName string = acrModule.outputs.acrName
