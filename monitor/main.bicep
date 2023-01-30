// This file is the main file for deploying shared monitoring resources
// It deploys monitoring resource group and resourcs inside that
// through the module "monitor.bicep"

targetScope = 'subscription'

@description('Location to create the resource group in')
param location string

@description('Base prefix of all resources')
param baseName string 

//// Resources

// Creates a resoruce group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${baseName}-monitor-rg'
  location: location

}

//// Modules

// Deploy resources into resourcegroup
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
