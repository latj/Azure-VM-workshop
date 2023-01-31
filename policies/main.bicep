// This file is the main file for configuring and assigning policies
// It deploys 
// - A policy resourcegroup
// - A managed idetity in the policy resourcegroup through the module "identity.bicep"
// - A role assignment for the managed identity over the current subscription scope
// - A set of custom policies through the module "customPolicies.bicep"
// - A set of policy assignments through the module "policyAssignments.bicep"

targetScope = 'subscription'

@description('Location to create the resource group in')
param location string

@description('Base prefix of all resources')
param baseName string 

@description('Set to true to enable backup policy')
param enableBackupPolicy bool = false

@description('Set to true to enable data collection policy')
param enableDataCollectionPolicy bool = false

@description('Set to true to deny public IP adresses on network interface cards')
param enableDenyPublicIp bool = false

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

module customPolicies 'customPolicies.bicep' = {
  name: '${deployment().name}-customPolicies'
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
    enableDenyPublicIp: enableDenyPublicIp
    winAmaPolicyId: customPolicies.outputs.winAmaId
    winDcrPolicyId: customPolicies.outputs.winDcrId
    linuxAmaPolicyId: customPolicies.outputs.linuxAmaId
    linuxDcrPolicyId: customPolicies.outputs.linuxDcrId
  }
}

//// Outputs
