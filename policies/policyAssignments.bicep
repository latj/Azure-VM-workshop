targetScope = 'subscription'

@description('Location to create the resource group in')
param location string = 'SwedenCentral'

@description('Base prefix of all resources')
param baseName string 

@description('Id of user assigned managed identity to use for Azure policy')
param policyIdentityId string 

//// Variables

//// Resources

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
    name: '${baseName}-configure-ama-on-winvm'
    location: location
    identity: {
      type: 'UserAssigned'
      userAssignedIdentities: {
        '${policyIdentityId}': {}
      }
    }
    properties: {
        policyDefinitionId: tenantResourceId('Microsoft.Authorization/policyDefinitions', 'ca817e41-e85a-4783-bc7f-dc532d36235e')
    }
}

//// Modules

//// Outputs



