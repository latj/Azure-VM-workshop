/// Global Settings ////

targetScope = 'subscription'

/// Params ////

// Names and identifiers//
@description('Base prefix of all resources')
param BaseName string = 'spoke'

param location string = 'northeurope'

@allowed([
  'weu'
  'neu'
])
param regionname string = 'neu'

//Remote VNET peer and Routetable//
@description('description')
param GatewayRouteTable string

@description('description')
param ConnectionHubVNETName string

@description('description')
param ConnectionhubNameRG string

@description('description')
param ConnectionhubNameSubID string



//Network properties//
@description('CIDR block representing the address space of the Azure VNet')
param SpokeAzureVNetAddressPrefix string
param indexnumber string
param VNETPeer01 string

@description('The HubprefixAdd')
param FirewallInternalIP string

param subnets object = {}

param routes array = [
  {
    name: 'DefaultRoute'
    addressprefix: '0.0.0.0/0'
  }
]

param tagvalue object = {
  fabobject: '12345'
}


/// Variables ///

var SpokeVNETName = '${BaseName}-${regionname}-spoke${indexnumber}-vnet'


//// Resources ////

///Resource groups///

resource BaseName_regionname_network_rg 'Microsoft.Resources/resourceGroups@2020-06-01' =  {
  location: location
  name: '${BaseName}-${regionname}-network-rg'
  properties: {
  }
  tags: tagvalue
}



/// Resources
module network './network.bicep' = {
  scope: resourceGroup(BaseName_regionname_network_rg.name) 
  params:{
  BaseName: BaseName
  SpokeVNETName: SpokeVNETName
  ConnectionHubVNETName: ConnectionHubVNETName
  ConnectionhubNameSubID: ConnectionhubNameSubID
  ConnectionhubNameRG: ConnectionhubNameRG
  regionname:regionname
  routes:routes
  SpokeAzureVNetAddressPrefix:SpokeAzureVNetAddressPrefix
  subnets: subnets
  VNETPeer01: VNETPeer01
  FirewallInternalIP: FirewallInternalIP
  GatewayRouteTable:GatewayRouteTable
  location: location
  }
  name: 'spoke'
  dependsOn: [
     
  ]
}
