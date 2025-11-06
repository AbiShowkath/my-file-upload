param keyVaultName string
param storageAccountName string
@secure()
param connectionString string

resource keyVault 'Microsoft.KeyVault/vaults@2025-05-01' existing = {
  name: keyVaultName
}

resource connStrKvSecret 'Microsoft.KeyVault/vaults/secrets@2025-05-01' = {
  parent: keyVault
  name: '${storageAccountName}-conn-str'
  properties: {
    value: connectionString
  }
}
