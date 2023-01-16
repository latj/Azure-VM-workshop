targetScope = 'resourceGroup'

param fwpolicyname string = 'fwpolicy-northeurope'
param location string = resourceGroup().location

resource firewallpolicy 'Microsoft.Network/firewallPolicies@2021-05-01' = {
  name: fwpolicyname
  location: location
  properties: {
    sku: {
      tier: 'Standard'
    }
  }
}

output firewallid string = firewallpolicy.id
