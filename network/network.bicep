
@description('CIDR block representing the address space of the Azure VNet')
param location string

@description('Base prefix of all resources')
param BaseName string

@description('CIDR block representing the address space of the Azure VNet')
param azureVNetAddressPrefix string

@description('CIDR block for VM subnet, subset of azureVNetAddressPrefix address space')
param parSubnets array




//// Variables
var varSubnetProperties = [for subnet in parSubnets: {
  name: subnet.name
  properties: {
    addressPrefix: subnet.ipAddressRange
     networkSecurityGroup: subnet.name != 'AzureBastionSubnet' ? {id: GenericSubnettNSG.id} : {
     id: AzureBastionSubnetNSG.id
    } 
  }
}]

//// Resources
/* resource BaseName_VNET 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: toLower('${BaseName}-VNET')
} */

resource BaseName_VNET 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: toLower('${BaseName}-VNET')
  location: location
  properties: {
    dhcpOptions: {
      //dnsServers: dnsservers
    }
    addressSpace: {
      addressPrefixes: [
        azureVNetAddressPrefix
      ]
    }
    subnets: varSubnetProperties
  }
  dependsOn: [
    //AzureBastionSubnetNSG
  ]
}


resource AzureBastionSubnetNSG 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: 'AzureBastionSubnet'
  location: location
  tags: {
    SubscriptionName: subscription().displayName
  }
  properties: {
    securityRules: [
      {
        name: 'AllowRDP-IN'
        properties: {
          description: 'RDP access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 210
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowSSH-IN'
        properties: {
          description: 'Allows SSH access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 211
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowInBoundAll'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 4000
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowOutboundAll'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 4000
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
  dependsOn: []
}

resource GenericSubnettNSG 'Microsoft.Network/networkSecurityGroups@2022-07-01' = {
  name: 'spoke-subnet-nsg'
  location: location
  tags: {
    SubscriptionName: subscription().displayName
  }
  properties: {
    securityRules: [
      {
        name: 'AllowRDP-IN'
        properties: {
          description: 'RDP access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '3389'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 210
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowSSH-IN'
        properties: {
          description: 'Allows SSH access'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 211
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowInBoundAll'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 4000
          direction: 'Inbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
      {
        name: 'AllowOutboundAll'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 4000
          direction: 'Outbound'
          sourcePortRanges: []
          destinationPortRanges: []
          sourceAddressPrefixes: []
          destinationAddressPrefixes: []
        }
      }
    ]
  }
  dependsOn: []
}




output virtualnetwork string = BaseName_VNET.name
