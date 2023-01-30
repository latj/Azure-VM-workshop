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

@description('Custom Data to send to the VM')
param customData string = ''

@description('Sets the value of the backup tag')
param enableBackupTag bool

var publisher = 'RedHat'
var offer = 'RHEL'
var OSVersion = '8_4'
var vmSize = 'Standard_B2s'
var vmName = '${baseName}-linux-vm'
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
    osProfile: union({
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }, (customData == '') ? {} : {
      customData: base64(customData)
    })
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
          storageAccountType: 'Standard_LRS'
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

/// OUTPUTS
output vmName string = vm.name
