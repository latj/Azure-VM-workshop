// This file contains policy assignments
// Both custom and built in policies are assigned to the current subscription scopes

targetScope = 'subscription'

@description('Location to create the resource group in')
param location string

@description('Base prefix of all resources')
param baseName string

@description('Id of user assigned managed identity to use for Azure policy')
param policyIdentityId string

@description('Id of the data collection rule to use with Azure policy')
param dcrId string

@description('Set to true to enable backup policy')
param enableBackupPolicy bool = false

@description('Set to true to enable data collection policy')
param enableDataCollectionPolicy bool = false

@description('Set to true to deny public IP adresses on network interface cards')
param enableDenyPublicIp bool = false

@description('Settings for enableing Azure Security Baseline')
param securityBaseline bool = false

param winAmaPolicyId string
param winDcrPolicyId string
param linuxAmaPolicyId string
param linuxDcrPolicyId string
param outputCustomProfile string

//// Variables
//var deploy_log_analytics_extension_for_linux_vms = tenantResourceId('Microsoft.Authorization/policyDefinitions', '053d3325-282c-4e5c-b944-24faffd30d77')
//var deploy_configure_log_analytics_extension_to_be_enabled_on_windows_virtual_machine = tenantResourceId('Microsoft.Authorization/policyDefinitions', '0868462e-646c-4fe3-9ced-a733534b6a2c')
//var configure_windows_virtual_machines_to_run_Azure_Monitor_Agent_using_system_assigned_managed_identity = tenantResourceId('Microsoft.Authorization/policyDefinitions', 'ca817e41-e85a-4783-bc7f-dc532d36235e')
//var deploy_prerequisites_to_enable_guest_configuration_policies_on_virtual_machines = tenantResourceId('Microsoft.Authorization/policySetDefinitions', '12794019-7a00-42cf-95c2-882eed337cc8')
//var configure_windows_virtual_machines_to_be_associated_with_a_data_collection_rule_or_a_data_collection_endpoint = tenantResourceId('Microsoft.Authorization/policyDefinitions', '244efd75-0d92-453c-b9a3-7d73ca36ed52')
//var configure_linux_virtual_machines_to_be_associated_with_a_data_collection_rule_or_a_data_collection_endpoint = tenantResourceId('Microsoft.Authorization/policyDefinitions', '58e891b9-ce13-4ac3-86e4-ac3e1f20cb07')

var network_interfaces_should_not_have_public_ips = tenantResourceId('Microsoft.Authorization/policyDefinitions', '83a86a26-fd1f-447c-b59d-e51f44264114')
var configure_virtual_machines_to_be_onboarded_to_azure_automanage_with_custom_configuration_profile = tenantResourceId('Microsoft.Authorization/policyDefinitions', 'b025cfb4-3702-47c2-9110-87fe0cfcc99b')
var configure_backup_on_virtual_machines_with_a_given_tag_to_a_new_recovery_services_vault_with_a_default_policy = tenantResourceId('Microsoft.Authorization/policyDefinitions', '83644c87-93dd-49fe-bf9f-6aff8fd0834e')
//// Resources


// Policy assignment that deploys the azure monitor agent on windows VMs (Custom policy)
// The policy assignment is only deployed if the paramarter `enableDataCollectionPolicy` is set to true
resource winAmaAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = if(enableDataCollectionPolicy) {
  name: '${baseName}-configure-ama-on-winvm'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${policyIdentityId}': {}
    }
  }
  properties: {
    policyDefinitionId: winAmaPolicyId
  }
}

// Policy assignment that deploys the azure monitor agent on Linux VMs (Custom policy)
// The policy assignment is only deployed if the paramarter `enableDataCollectionPolicy` is set to true
resource linuxAmaAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = if(enableDataCollectionPolicy) {
  name: '${baseName}-configure-ama-on-linuxvm'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${policyIdentityId}': {}
    }
  }
  properties: {
    policyDefinitionId: linuxAmaPolicyId
  }
}

// Policy assignment that deploys data collection rules on Windows VMs (Custom policy)
// The policy assignment is only deployed if the paramarter `enableDataCollectionPolicy` is set to true
resource dcrAssignmentWin 'Microsoft.Authorization/policyAssignments@2022-06-01' = if(enableDataCollectionPolicy) {
  name: '${baseName}-configure-dcr-on-winvm'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${policyIdentityId}': {}
    }
  }
  properties: {
    policyDefinitionId: winDcrPolicyId
    parameters: {
      dcrResourceId: {
        value: dcrId
      }
    }
  }
}

// Policy assignment that deploys data collection rules on Linux VMs (Custom policy)
// The policy assignment is only deployed if the paramarter `enableDataCollectionPolicy` is set to true
resource dcrAssignmentLinux 'Microsoft.Authorization/policyAssignments@2022-06-01' = if(enableDataCollectionPolicy) {
  name: '${baseName}-configure-dcr-on-linuxvm'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${policyIdentityId}': {}
    }
  }
  properties: {
    policyDefinitionId: linuxDcrPolicyId
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

// Policy assignment that denies network interface cards a public IP
// The policy assignment is only deployed if the paramarter `enableDenyPublicIp` is set to true
resource denyPublicIpNicAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = if(enableDenyPublicIp) {
  name: '${baseName}-deny-public-ip'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${policyIdentityId}': {}
    }
  }
  properties: {
    policyDefinitionId: network_interfaces_should_not_have_public_ips
  }
}

// Policy assignment that assign VM to Automanage BP Custom Profile
// The policy assignment is only deployed if the paramarter `securityBaseline` is set to true
resource AssignSecurityBaseline 'Microsoft.Authorization/policyAssignments@2022-06-01' = if(securityBaseline) {
  name: '${baseName}-automanage-custom-profile'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${policyIdentityId}': {}
    }
  }
  properties: {
    policyDefinitionId: configure_virtual_machines_to_be_onboarded_to_azure_automanage_with_custom_configuration_profile
    parameters: {
      configurationProfile: {
        value: outputCustomProfile
      }
    }
  }
}


/* 
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

resource lawAgentWin 'Microsoft.Authorization/policyAssignments@2022-06-01' = if(enableDataCollectionPolicy) {
  name: '${baseName}-configure-law-on-winvm'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${policyIdentityId}': {}
    }
  }
  properties: {
    policyDefinitionId: deploy_configure_log_analytics_extension_to_be_enabled_on_windows_virtual_machine
    parameters: {
      logAnalytics: {
        value: logAnalyticsId
      }
    }
  }
}

resource lawAgentLinux 'Microsoft.Authorization/policyAssignments@2022-06-01' = if(enableDataCollectionPolicy) {
  name: '${baseName}-configure-law-on-linuxvm'
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${policyIdentityId}': {}
    }
  }
  properties: {
    policyDefinitionId: deploy_log_analytics_extension_for_linux_vms
    parameters: {
      logAnalytics: {
        value: logAnalyticsId
      }
    }
  }
}*/


//// Modules

//// Outputs
