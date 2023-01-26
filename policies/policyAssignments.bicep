targetScope = 'subscription'

@description('Location to create the resource group in')
param location string = 'SwedenCentral'

@description('Base prefix of all resources')
param baseName string

@description('Id of user assigned managed identity to use for Azure policy')
param policyIdentityId string

@description('Id of the data collection rule to use with Azure policy')
param dcrId string

@description('Set to true to enable backup policy')
param enableBackupPolicy bool

@description('Set to true to enable data collection policy')
param enableDataCollectionPolicy bool = false

//// Variables
var configure_windows_virtual_machines_to_run_Azure_Monitor_Agent_using_system_assigned_managed_identity = tenantResourceId('Microsoft.Authorization/policyDefinitions', 'ca817e41-e85a-4783-bc7f-dc532d36235e')
var deploy_prerequisites_to_enable_guest_configuration_policies_on_virtual_machines = tenantResourceId('Microsoft.Authorization/policySetDefinitions', '12794019-7a00-42cf-95c2-882eed337cc8')
var configure_backup_on_virtual_machines_with_a_given_tag_to_a_new_recovery_services_vault_with_a_default_policy = tenantResourceId('Microsoft.Authorization/policyDefinitions', '83644c87-93dd-49fe-bf9f-6aff8fd0834e')
var configure_windows_virtual_machines_to_be_associated_with_a_data_collection_rule_or_a_data_collection_endpoint = tenantResourceId('Microsoft.Authorization/policyDefinitions', '244efd75-0d92-453c-b9a3-7d73ca36ed52')
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

resource amaAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
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

// Policy assignment that deploys a data collection rule on windows VM's
// The policy assignment is only deployed if the paramarter `enableDataCollectionPolicy` is set to true
resource dcrAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = if(enableDataCollectionPolicy) {
  name: '${baseName}-configure-dcr-on-winvm'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${policyIdentityId}': {}
    }
  }
  properties: {
    policyDefinitionId: configure_windows_virtual_machines_to_be_associated_with_a_data_collection_rule_or_a_data_collection_endpoint
    parameters: {
      dcrResourceId: {
        value: dcrId
      }
    }
  }
}

// Policy assignment that deploys backup configuration on virtual machines
// The policy assignment is only deployed if the paramarter `enableBackupPolicy` is set to true
resource backupAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = if(enableBackupPolicy) {
  name: '${baseName}-configure-backup'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${policyIdentityId}': {}
    }
  }
  properties: {
    policyDefinitionId: configure_backup_on_virtual_machines_with_a_given_tag_to_a_new_recovery_services_vault_with_a_default_policy
    parameters: {
      inclusionTagName: {
        value: 'backup'
      }
      inclusionTagValue: {
        value: [
          'yes'
        ]
      }
    }
  }
}

//// Modules

//// Outputs
