targetScope = 'subscription'

@description('Location to create the resource group in')
param location string

@description('Base prefix of all resources')
param baseName string 

@description('Name of the virtual network to attach the VM to')
param networkNamePostfix string

@description('Name of the subnet to attach the VM to')
param subnetName string

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Set to true to enable disk encryption')
param enableDiskEncryption bool = false

@description('Sets the value of the backup tag')
param enableBackupTag bool = false

@description('Sets to true to enable VM Insights')
param enableVmInsights bool = false

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

//// Variables

//// Resources

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${baseName}-vm-rg'
  location: location
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  scope: resourceGroup('${baseName}-network-rg')
  name: '${baseName}-${networkNamePostfix}'
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  parent: vnet
  name: subnetName
}

//// Modules

module vmModule 'vm.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-vm'
  params: {
    baseName: baseName
    location: location
    subnetId: subnet.id
    adminPassword: adminPassword
    adminUsername: adminUsername
    enableBackupTag: enableBackupTag
  }
}

module diskEncryptionModule 'diskEncryption.bicep' = if (enableDiskEncryption) {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-diskEncryption'
  params: {
    baseName: baseName
    location: location
    vmName: vmModule.outputs.vmName
  }
}

module vmInsightsModule 'vmInsights.bicep' = if (enableVmInsights) {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-vmInsights'
  params: {
    baseName: baseName
    location: location
    vmName: vmModule.outputs.vmName
    logAnalyticsName: '${baseName}-logs'
  }
}




//// Outputs



