targetScope = 'subscription'

@description('Location to create the resource group in')
param location string = 'SwedenCentral'

@description('Base prefix of all resources')
param baseName string

@description('Id of user assigned managed identity to use for Azure policy')
param policyIdentityId string

//// Variables
var configure_windows_virtual_machines_to_run_Azure_Monitor_Agent_using_system_assigned_managed_identity = tenantResourceId('Microsoft.Authorization/policyDefinitions', 'ca817e41-e85a-4783-bc7f-dc532d36235e')
var deploy_prerequisites_to_enable_guest_configuration_policies_on_virtual_machines = tenantResourceId('Microsoft.Authorization/policySetDefinitions', '12794019-7a00-42cf-95c2-882eed337cc8')
//// Resources

resource guestConfigurationPrerequisitesAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: '${baseName}-configure-guestconfiguration'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${policyIdentityId}': {}
    }
  }
  properties: {
    policyDefinitionId: deploy_prerequisites_to_enable_guest_configuration_policies_on_virtual_machines
  }
}

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
    policyDefinitionId: configure_windows_virtual_machines_to_run_Azure_Monitor_Agent_using_system_assigned_managed_identity
  }
}

//// Modules

//// Outputs
