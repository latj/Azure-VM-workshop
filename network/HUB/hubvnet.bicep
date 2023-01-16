//////////////////////
//////Parameters//////
//////////////////////

param hubNetwork object = {
  name: 'vnet-hub'
  addressPrefix: '10.0.0.0/22'
}

param azureFirewall object = {
  name: 'fw-hub'
  policyid: '/subscriptions/e8acb171-66bd-488c-950d-7724bfb7ffae/resourceGroups/fwpolicy-rg/providers/Microsoft.Network/firewallPolicies/fwpolicy-northeurope'
  publicIPAddressName: 'pip-fw-hub'
  subnetName: 'AzureFirewallSubnet'
  subnetPrefix: '10.0.3.0/26'
  routeName: 'r-nexthop-to-fw'
}

param bastionHost object = {
  name: 'bastion-hub'
  publicIPAddressName: 'pip-bastion-hub'
  subnetName: 'AzureBastionSubnet'
  nsgName: 'nsg-bastion-hub'
  subnetPrefix: '10.0.1.0/29'
}

param privateendpoints object = {
  name: 'privateendpoints'
  subnetName: 'PrivateEndpointSubnet'
  subnetPrefix: '10.0.2.0/27'
  
}

param applicationgateway object = {
  name: 'applicationgateway'
  subnetName: 'ApplicationgatewaySubnet'
  subnetPrefix: '10.0.0.0/24'
  
}

param location string = resourceGroup().location

param parAzBastionEnabled bool = false


//////////////////////
//////Variables//////
//////////////////////

var logAnalyticsWorkspaceName = uniqueString(subscription().subscriptionId, resourceGroup().id)


//////////////////////
//////Resources//////
//////////////////////
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource vnetHub 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: hubNetwork.name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubNetwork.addressPrefix
      ]
    }
    subnets: [
   {
         name: privateendpoints.subnetName
          properties: {
             addressPrefix: privateendpoints.subnetPrefix
            routeTable:  {
        id: azureFirewallRoutes.id
      }
         }
      }
    {
      name: applicationgateway.subnetName
      properties: {
        addressPrefix: applicationgateway.subnetPrefix
      }
      }
    {
      name: azureFirewall.subnetName
      properties: {
       addressPrefix: azureFirewall.subnetPrefix
      }
     }
     {
       name: bastionHost.subnetName
       properties: {
        addressPrefix: bastionHost.subnetPrefix
     }
   }
   ]
  }
}

/// For easy referencing
resource azurefirewallsubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01'  existing = {
  name: azureFirewall.subnetName
  parent: vnetHub
}
resource azurebastion 'Microsoft.Network/virtualNetworks/subnets@2021-05-01'  existing = {
  name: bastionHost.subnetName
  parent: vnetHub
}

resource diahVnetHub 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'diahVnetHub'
  scope: vnetHub
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'VMProtectionAlerts'
        enabled: true
      }
    ]
  }
}

resource pipFirewall 'Microsoft.Network/publicIPAddresses@2021-05-01'= {
  name: azureFirewall.publicIPAddressName
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource firewall 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: azureFirewall.name
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Standard'
    }
    firewallPolicy: {
      id: azureFirewall.policyid
    }
    ipConfigurations: [
      {
        name: azureFirewall.name
        properties: {
          publicIPAddress: {
            id: pipFirewall.id
          }
          subnet: {
            id: azurefirewallsubnet.id
          }
        }
      }
    ]
  }
}


resource diagFirewall 'microsoft.insights/diagnosticSettings@2017-05-01-preview' = {
  name: 'diagFirewall'
  scope: firewall
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
      }
      {
        category: 'AzureFirewallDnsProxy'
        enabled: true
      }
    ]
  }
}


resource azureFirewallRoutes 'Microsoft.Network/routeTables@2020-05-01' = {
  name: azureFirewall.routeName
  location: location
  properties: {
    disableBgpRoutePropagation: false
  }
}




resource bastionPip 'Microsoft.Network/publicIPAddresses@2020-06-01' = if (parAzBastionEnabled) {
  name: bastionHost.publicIPAddressName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nsgBastion 'Microsoft.Network/networkSecurityGroups@2020-06-01' = if (parAzBastionEnabled) {
  name: bastionHost.nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'bastion-in-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'bastion-control-in-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'bastion-in-host'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'bastion-vnet-out-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'bastion-azure-out-allow'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'bastion-out-host'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'bastion-out-deny'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

resource bastionHostResource 'Microsoft.Network/bastionHosts@2020-06-01' = if (parAzBastionEnabled) {
  name: bastionHost.Name
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconf'
        properties: {
          subnet: {
            id: azurebastion.id
          }
          publicIPAddress: {
            id: bastionPip.id
          }
        }
      }
    ]
  }
}



////Outputs
output HubVnetID string = vnetHub.id
output HubVnetname string = vnetHub.name
output GatewaYRouteTable string = azureFirewallRoutes.name
output FirewallInternalIP string = firewall.properties.ipConfigurations[0].properties.privateIPAddress
