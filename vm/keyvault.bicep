@description('Base prefix of all resources')
param baseName string 

@description('Location for all resources')
param location string = resourceGroup().location

resource vault 'Microsoft.KeyVault/vaults@2021-11-01-preview' = {
  name: '${baseName}-${uniqueString(resourceGroup().id)}kv'
  location: location
  properties: {
    accessPolicies:[]
    enableRbacAuthorization: false
    enableSoftDelete: false
    enabledForDeployment: false
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: false
    tenantId: subscription().tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
    }
  }
}

resource key 'Microsoft.KeyVault/vaults/keys@2021-11-01-preview' =  {
  parent: vault
  name: '${baseName}-diskEncryptionKey'
  properties: {
    kty: 'RSA'
    keySize: 4096
  }
}

//// OUTPUTS
output vaultId string = vault.id
output vaultUri string = vault.properties.vaultUri
output keyUriWithVersion string = key.properties.keyUriWithVersion
