targetScope = 'subscription'

@description('Location to create the resource group in')
param location string = 'SwedenCentral'

@description('Base prefix of all resources')
param baseName string 

@description('Name of the virtual network to attach the VM to')
param networkNamePostfix string

@description('Name of the subnet to attach the VM to')
param subnetName string

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Set to true to enable disk encryption')
param diskEncryption bool = false

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
  name: 'vm'
  params: {
    baseName: baseName
    location: location
    subnetId: subnet.id
    adminPassword: adminPassword
    adminUsername: adminUsername
    diskEncryption: diskEncryption
  }
}

module diskEncryptionModule 'diskEncryption.bicep' = if (diskEncryption) {
  scope: resourceGroup(rg.name)
  name: 'diskEncryption'
  params: {
    baseName: baseName
    location: location
    vmName: vmModule.outputs.vmName
  }
}

//// Outputs



