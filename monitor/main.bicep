targetScope = 'subscription'

@description('Location to create the resource group in')
param location string

@description('Base prefix of all resources')
param baseName string 

//// Resources

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${baseName}-monitor-rg'
  location: location

}

//// Modules

module monitor 'monitor.bicep' =  {
  scope: resourceGroup(rg.name)
  name: '${deployment().name}-monitor'
  params: {
    baseName: baseName
    location: location
  }
}

//// Outputs

output dcrId string = monitor.outputs.dcrId
output logAnalyticsWorkspaceId string = monitor.outputs.logAnalyticsWorkspaceId
