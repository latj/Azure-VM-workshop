// This file is the main file for deploying shared networking resources
// It deploys 
// - A network resource group 
// - A vnet, nsg, subnets etc through the module "network.bicep"
// - An Azure Bastion host through the module "AzureBastion.bicep"

targetScope = 'subscription'

@description('CIDR block representing the address space of the Azure VNet')
param location string

param parSubnets array

//var AzureFirewallManagementSubnet = resourceId('Microsoft.Network/virtualNetworks/subnets', baseName_VNET.name, 'AzureFirewallManagementSubnet')
@description('Base prefix of all resources')
param baseName string 

@description('CIDR block representing the address space of the Azure VNet')
param azureVNetAddressPrefix string

//// Variables

//// Resources

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${baseName}-network-rg'
  location: location

}

//// Modules

module network 'network.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'network'
  params: {
    baseName: baseName
    location: location
    azureVNetAddressPrefix: azureVNetAddressPrefix
    parSubnets: parSubnets
  }
}

module bastion 'AzureBastion.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'bastion'
  params: {
    baseName: baseName
    location: location
    virtualnetwork: network.outputs.virtualnetwork
  }
}

//// Outputs



