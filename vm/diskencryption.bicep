@description('Base prefix of all resources')
param baseName string 

@description('Location for all resources')
param location string = resourceGroup().location

@description('Vm to apply encryption on')
param vmName string

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' existing = {
  name: vmName
}

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

resource DiskEncryption 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = {
  name: 'AzureDiskEncryption'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Security'
    type: 'AzureDiskEncryption'
    typeHandlerVersion: '2.2'
    autoUpgradeMinorVersion: true
    forceUpdateTag: '1.0'
    settings: {
      EncryptionOperation: 'EnableEncryption'
      KeyVaultURL: vault.properties.vaultUri
      KeyVaultResourceId: vault.id
      KekVaultResourceId: vault.id
      KeyEncryptionKeyURL: key.properties.keyUriWithVersion
      VolumeType: 'All'
      ResizeOSDisk: false
    }
  }
}
