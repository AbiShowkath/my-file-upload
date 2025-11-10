param location string = resourceGroup().location
param namePrefix string

param acrName string
param acrLoginServer string = '${acrName}.azurecr.io'
param backendImage string = '${acrLoginServer}/${namePrefix}-api:latest'

param kvName string
param saName string
param appId string
param tenantId string
@secure()
param password string

var appName = '${namePrefix}app'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${appName}-logs'
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource containerAppEnv 'Microsoft.App/managedEnvironments@2025-01-01' = {
  name: '${appName}-env'
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

resource backendApp 'Microsoft.App/containerApps@2025-01-01' = {
  name: '${appName}-backend'
  location: location
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true
        targetPort: 8000
        transport: 'auto'
        allowInsecure: false
      }
      secrets: [
        {
          name: 'acr-password'
          value: acr.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: acrLoginServer
          username: acr.listCredentials().username
          passwordSecretRef: 'acr-password'
        }
      ]
    }
    template: {
      containers: [
        {
          name: 'backend'
          image: backendImage
          
          resources: {
            cpu: 1
            memory: '2.0Gi'
          }
          env: [
            {
              name: 'ORIGIN'
              value: 'http://localhost:3000'
            }
            {
              name: 'KEY_VAULT_NAME'
              value: kvName
            }
            {
              name: 'STORAGE_ACCOUNT_NAME'
              value: saName
            }
            {
              name: 'AZURE_CLIENT_ID'
              value: appId
            }
            {
              name: 'AZURE_TENANT_ID'
              value: tenantId
            }
            {
              name: 'AZURE_CLIENT_SECRET'
              value: password
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 3
      }
    }
  }
}
