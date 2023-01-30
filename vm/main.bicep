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

@description('Custom Data to send to the VM')
param customData string = ''

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

//// Modules - Virtual Machines

module linuxVmModule 'linux.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-linux-vm'
  params: {
    baseName: baseName
    location: location
    subnetId: subnet.id
    adminPassword: adminPassword
    adminUsername: adminUsername
    enableBackupTag: enableBackupTag
    customData: customData
  }
}

module windowsVmModule 'windows.bicep' = {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-win-vm'
  params: {
    baseName: baseName
    location: location
    subnetId: subnet.id
    adminPassword: adminPassword
    adminUsername: adminUsername
    enableBackupTag: enableBackupTag
  }
}

//// Modules - Disk Encryption
module diskEncryptionWindowsModule 'diskEncryption.bicep' = if (enableDiskEncryption) {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-WindowsDiskEncryption'
  params: {
    baseName: baseName
    location: location
    vmName: windowsVmModule.outputs.vmName
  }
}

module diskEncryptionLinuxModule 'diskEncryption.bicep' = if (enableDiskEncryption) {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-LinuxDiskEncryption'
  params: {
    baseName: baseName
    location: location
    vmName: linuxVmModule.outputs.vmName
  }
}

//// Modules - VM Insights

module vmInsightsWindowsModule 'vmInsights.bicep' = if (enableVmInsights) {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-WindowsVmInsights'
  params: {
    baseName: baseName
    location: location
    vmName: windowsVmModule.outputs.vmName
    logAnalyticsName: '${baseName}-logs'
    isWindows: true
  }
}

module vmInsightsLinuxModule 'vmInsights.bicep' = if (enableVmInsights) {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-LinuxVmInsights'
  params: {
    baseName: baseName
    location: location
    vmName: linuxVmModule.outputs.vmName
    logAnalyticsName: '${baseName}-logs'
    isLinux: true
  }
}



//// Outputs



