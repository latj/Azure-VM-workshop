targetScope = 'resourceGroup'

/// Params ////

@description('description')
param GatewayRouteTable string

@description('description')
param ConnectionHubVNETName string


@description('CIDR block representing the address space of the Azure VNet')
param SpokeAzureVNetAddressPrefix string

param SpokeVNETName string


@description('The HubprefixAdd')
param FirewallInternalIP string

param spokevnet string

resource HubRT 'Microsoft.Network/routeTables@2021-02-01' existing = {
  name: GatewayRouteTable
}

resource HubRTspoke 'Microsoft.Network/routeTables/routes@2021-02-01' = {
  name: SpokeVNETName
  parent: HubRT
   properties: {
      addressPrefix: SpokeAzureVNetAddressPrefix
      nextHopIpAddress: FirewallInternalIP
      nextHopType: 'VirtualAppliance'
   }
}

resource HubCentral 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: ConnectionHubVNETName
  
}

resource VNETPeer01 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2021-02-01' = {
  name: SpokeVNETName
  parent: HubCentral
   properties: {
     allowForwardedTraffic: true
     allowGatewayTransit: true
     allowVirtualNetworkAccess: true
     useRemoteGateways: false
     remoteVirtualNetwork: {
        id: spokevnet
   }
  
}
}
