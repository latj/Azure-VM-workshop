targetScope = 'subscription'


@description('CIDR block representing the address space of the Azure VNet')
param location string

param parSubnets array

//var AzureFirewallManagementSubnet = resourceId('Microsoft.Network/virtualNetworks/subnets', BaseName_VNET.name, 'AzureFirewallManagementSubnet')
@description('Base prefix of all resources')
param BaseName string 

@description('CIDR block representing the address space of the Azure VNet')
param azureVNetAddressPrefix string




//// Variables

//// Resources

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${BaseName}-rg'
  location: location

}

//// Modules

module network 'network.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'network'
  params: {
    BaseName: BaseName
    location: location
    azureVNetAddressPrefix: azureVNetAddressPrefix
    parSubnets: parSubnets
  }
}

module bastion 'AzureBastion.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'bastion'
  params: {
    BaseName: BaseName
    location: location
    virtualnetwork: network.outputs.virtualnetwork
  }
}


//// Outputs



