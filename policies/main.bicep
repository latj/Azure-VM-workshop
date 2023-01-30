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

resource dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' existing = {
  scope: resourceGroup('${baseName}-monitor-rg')
  name: '${baseName}-default-dcr'
}

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
  name: '${deployment().name}-policyIdentity'
  params: {
    name: '${baseName}-policyIdentity'
    location: location
  }
}

module policyAssignments 'policyAssignments.bicep' = {
  name: '${deployment().name}-policyAssignments'
  params: {
    baseName: baseName
    location: location
    policyIdentityId: identity.outputs.identityId
    dcrId: (enableDataCollectionPolicy) ? dcr.id : ''
    enableBackupPolicy: enableBackupPolicy
    enableDataCollectionPolicy: enableDataCollectionPolicy
  }
}








//// Outputs



