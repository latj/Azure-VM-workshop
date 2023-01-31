@description('Base prefix of all resources')
param baseName string 

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Id of the subnet to attach the VM to')
param subnetId string

@description('Settings for diskencryption. If empty diskencryption is not configured')
param diskEncryptionSettings object = {}

@description('Sets the value of the backup tag')
param enableBackupTag bool

var publisher = 'MicrosoftWindowsServer'
var offer = 'WindowsServer'
var OSVersion = '2022-datacenter'
var vmSize = 'Standard_D2as_v5'
var vmName = '${baseName}-win-vm'
var nicName = '${vmName}-nic'

resource nic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
  location: location
  tags: {
    backup: (enableBackupTag) ? 'yes' : 'no'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        patchSettings: {
          assessmentMode: 'ImageDefault'
          patchMode: 'AutomaticByPlatform'
        }
      }
    }
    storageProfile: {
      imageReference: {
        publisher: publisher
        offer: offer
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

resource diskEncryption 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = if(!empty(diskEncryptionSettings)) {
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
      KeyVaultURL: diskEncryptionSettings.vaultUri
      KeyVaultResourceId: diskEncryptionSettings.vaultId
      KekVaultResourceId: diskEncryptionSettings.vaultId
      KeyEncryptionKeyURL: diskEncryptionSettings.keyUriWithVersion
      VolumeType: 'All'
      ResizeOSDisk: false
    }
  }
}

/// OUTPUTS
output vmName string = vm.name
