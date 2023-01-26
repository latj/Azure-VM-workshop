
@description('CIDR block representing the address space of the Azure VNet')
param location string
param virtualnetwork string

var AzureBastionSubnet = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualnetwork, 'AzureBastionSubnet')
@description('Base prefix of all resources')
param baseName string


//// Resources

resource bastionpublicIP 'Microsoft.Network/publicIPAddresses@2021-08-01' = {
  name: '${baseName}-pip-mgmt'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
  }
}

resource azurebastion 'Microsoft.Network/bastionHosts@2022-07-01' = {
  name: '${baseName}-bastion'
  location: location
  sku: {
     name: 'Basic'
  }
  properties: {
   ipConfigurations: [
     {
      name: 'ipconf'
       properties: {
        publicIPAddress: {
         id: bastionpublicIP.id
        }
        subnet: {
          id: AzureBastionSubnet
        }
       }
     }
   ]
 }
}

