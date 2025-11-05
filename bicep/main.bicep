param namePrefix string = 'fileupload'
param location string = resourceGroup().location

var managedIdentityName = '${namePrefix}-mi'

var keyVaultName = '${namePrefix}-kv-${uniqueString(resourceGroup().id)}'

var storageAccountName = toLower('${namePrefix}sa${uniqueString(resourceGroup().id)}')

// @minLength(5)
// @maxLength(50)
// @description('Provide a globally unique name of your Azure Container Registry')
// param acrName string = '${namePrefix}acr${uniqueString(resourceGroup().id)}'

module managedIdentityModule 'modules/managedIdentity.bicep' = {
  name: '${managedIdentityName}module'
  params: {
    location: location
    managedIdentityName: managedIdentityName
  }
}

module keyVaultModule 'modules/keyvault.bicep' = {
  name: '${keyVaultName}module'
  params: {
    location: location
    keyVaultName: keyVaultName
    managedIdentityName: managedIdentityName
  }
}

module storageAccountModule 'modules/storageAccounts.bicep' = {
  name: '${storageAccountName}module'
  params: {
    location: location
    storageAccountName: storageAccountName
    storageAccountType: 'Standard_LRS'
  }
}

resource sa 'Microsoft.Storage/storageAccounts@2025-01-01' existing = {
  name: storageAccountName
}

// Determine our connection string

var blobStorageConnectionString = 'DefaultEndpointsProtocol=https;AccountName=${sa.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(sa.id, sa.apiVersion).keys[0].value}'
// DefaultEndpointsProtocol=https;AccountName=${sa.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${sa.listKeys().keys[0].value}
// DefaultEndpointsProtocol=https;EndpointSuffix=${environment().suffixes.storage};AccountName=${sa.name};AccountKey=${listKeys(sa.id, sa.apiVersion).keys[0].value}

// Output our variable
// output blobStorageConnectionString string = blobStorageConnectionString
// output blobContainerName string = blobContainerName

module keyVaultSecretModule 'modules/keyvaultsecret.bicep' = {
  name: '${keyVaultName}secretmodule'
  params: {
    keyVaultName: keyVaultName
    storageAccountName: storageAccountName
    connectionString: blobStorageConnectionString
  }
}
