/// Global Settings ////
targetScope = 'resourceGroup'

/// Params ////

@description('Base prefix of all resources')
param BaseName string = 'Example-COMMON'

param SpokeVNETName string

@description('CIDR block representing the address space of the Azure VNet')
param SpokeAzureVNetAddressPrefix string

param VNETPeer01 string



@description('azure region')
param location string

@description('regionshortname')
param regionname string

param subnets object = {}

param routes array = [
  {
    name: 'DefaultRoute'
    addressprefix: '0.0.0.0/0'
  }
]

//Hub Network info
@description('description')
param GatewayRouteTable string

@description('description')
param ConnectionHubVNETName string

@description('description')
param ConnectionhubNameRG string

@description('The HubprefixAdd')
param FirewallInternalIP string

@description('description')
param ConnectionhubNameSubID string

//// Variables ////


var RouteTablename_var = toLower('${BaseName}-${regionname}-spoke-rt')
var NSGName_var = toLower('${BaseName}-${regionname}-spoke-nsg')


/// Resources ////

//Virtual network and subnets//
 
 resource VNETNAME 'Microsoft.Network/virtualNetworks@2020-11-01' = {
   name: SpokeVNETName
   location: location
   properties: {
     dhcpOptions: {
     }
     addressSpace: {
       addressPrefixes: [
         SpokeAzureVNetAddressPrefix
       ]
     }
     enableDdosProtection: false
   }
 }

resource spokenetworksubnet01 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' =  {
  name: subnets.subnets[0].name
  parent:VNETNAME
  properties: {
    privateEndpointNetworkPolicies: 'Enabled'
    addressPrefix: subnets.subnets[0].addressPrefix
    routeTable: {
      id: DefaultRT.id
    }
    networkSecurityGroup: {
      id: NSGName.id
    }
    serviceEndpoints: []
    delegations: []
  }  
}


// VNET Peering //
resource BaseName_VNET_ConnectionHub 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2019-11-01' = {
   name: 'ConnectionHub'
   parent: VNETNAME
   properties: {
     remoteVirtualNetwork: {
       id: VNETPeer01
     }
     allowVirtualNetworkAccess: true
     allowForwardedTraffic: true
     allowGatewayTransit: false
     useRemoteGateways: false
   }
   dependsOn: [
     
   ]
 }


 // Route Tables //

 resource DefaultRT 'Microsoft.Network/routeTables@2020-11-01' = {
  name: RouteTablename_var
  location: location
  properties: {
    disableBgpRoutePropagation: true
  }
  dependsOn: [
    VNETNAME
  ]
}

module remotenetwork './remotenetwork.bicep' = {
  scope: resourceGroup(ConnectionhubNameSubID, ConnectionhubNameRG) 
  params:{
    SpokeVNETName: SpokeVNETName
    ConnectionHubVNETName: ConnectionHubVNETName
    SpokeAzureVNetAddressPrefix:SpokeAzureVNetAddressPrefix
    FirewallInternalIP: FirewallInternalIP
    GatewayRouteTable:GatewayRouteTable
    spokevnet: VNETNAME.id
  }
  name: 'remote'
  dependsOn: [
     
  ]
}
//Routes

resource DefaultRTRoutes 'Microsoft.Network/routeTables/routes@2020-11-01' = [for item in routes: {
   name: item.name
   parent: DefaultRT
   properties:{
      addressPrefix: item.addressprefix
      nextHopType: 'VirtualAppliance'
     nextHopIpAddress: FirewallInternalIP
   }
}]

// NSG //
 resource NSGName 'Microsoft.Network/networkSecurityGroups@2018-08-01' = {
   name: NSGName_var
   location: location
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
     defaultSecurityRules: [
       {
         name: 'AllowVnetInBound'
         properties: {
           description: 'Allow inbound traffic from all VMs in VNET'
           protocol: '*'
           sourcePortRange: '*'
           destinationPortRange: '*'
           sourceAddressPrefix: 'VirtualNetwork'
           destinationAddressPrefix: 'VirtualNetwork'
           access: 'Allow'
           priority: 65000
           direction: 'Inbound'
           sourcePortRanges: []
           destinationPortRanges: []
           sourceAddressPrefixes: []
           destinationAddressPrefixes: []
         }
       }
       {
         name: 'AllowAzureLoadBalancerInBound'
         properties: {
           description: 'Allow inbound traffic from azure load balancer'
           protocol: '*'
           sourcePortRange: '*'
           destinationPortRange: '*'
           sourceAddressPrefix: 'AzureLoadBalancer'
           destinationAddressPrefix: '*'
           access: 'Allow'
           priority: 65001
           direction: 'Inbound'
           sourcePortRanges: []
           destinationPortRanges: []
           sourceAddressPrefixes: []
           destinationAddressPrefixes: []
         }
       }
       {
         name: 'DenyAllInBound'
         properties: {
           provisioningState: 'Succeeded'
           description: 'Deny all inbound traffic'
           protocol: '*'
           sourcePortRange: '*'
           destinationPortRange: '*'
           sourceAddressPrefix: '*'
           destinationAddressPrefix: '*'
           access: 'Deny'
           priority: 65500
           direction: 'Inbound'
           sourcePortRanges: []
           destinationPortRanges: []
           sourceAddressPrefixes: []
           destinationAddressPrefixes: []
         }
       }
       {
         name: 'AllowVnetOutBound'
         properties: {
           description: 'Allow outbound traffic from all VMs to all VMs in VNET'
           protocol: '*'
           sourcePortRange: '*'
           destinationPortRange: '*'
           sourceAddressPrefix: 'VirtualNetwork'
           destinationAddressPrefix: 'VirtualNetwork'
           access: 'Allow'
           priority: 65000
           direction: 'Outbound'
           sourcePortRanges: []
           destinationPortRanges: []
           sourceAddressPrefixes: []
           destinationAddressPrefixes: []
         }
       }
       {
         name: 'AllowInternetOutBound'
         properties: {
           provisioningState: 'Succeeded'
           description: 'Allow outbound traffic from all VMs to Internet'
           protocol: '*'
           sourcePortRange: '*'
           destinationPortRange: '*'
           sourceAddressPrefix: '*'
           destinationAddressPrefix: 'Internet'
           access: 'Allow'
           priority: 65001
           direction: 'Outbound'
           sourcePortRanges: []
           destinationPortRanges: []
           sourceAddressPrefixes: []
           destinationAddressPrefixes: []
         }
       }
       {
         name: 'DenyAllOutBound'
         properties: {
           description: 'Deny all outbound traffic'
           protocol: '*'
           sourcePortRange: '*'
           destinationPortRange: '*'
           sourceAddressPrefix: '*'
           destinationAddressPrefix: '*'
           access: 'Deny'
           priority: 65500
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
 


 //// Outputs ////
