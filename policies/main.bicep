targetScope = 'subscription'

@description('Location to create the resource group in')
param location string

@description('Base prefix of all resources')
param baseName string 

@description('Set to true to enable backup policy')
param enableBackupPolicy bool = false

@description('Set to true to enable data collection policy')
param enableDataCollectionPolicy bool = false

//// Variables
var contributorRoleDefinitonId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')

//// Resources

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${baseName}-policy-rg'
  location: location

}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(baseName, 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  properties: {
    principalId: identity.outputs.identityPrincipalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: contributorRoleDefinitonId
  }
}

//// Modules

module identity 'identity.bicep' = {
  scope: resourceGroup(rg.name)
  name: 'policyIdentity'
  params: {
    name: '${baseName}-policyIdentity'
    location: location
  }
}

module monitor 'monitor.bicep' = if(enableDataCollectionPolicy) {
  scope: resourceGroup(rg.name)
  name: 'monitor'
  params: {
    baseName: baseName
    location: location
  }
}

module policyAssignments 'policyAssignments.bicep' = {
  name: 'policyAssignments'
  params: {
    baseName: baseName
    location: location
    policyIdentityId: identity.outputs.identityId
    dcrId: (enableDataCollectionPolicy) ? monitor.outputs.dcrId : ''
    enableBackupPolicy: enableBackupPolicy
    enableDataCollectionPolicy: enableDataCollectionPolicy
  }
}








//// Outputs



