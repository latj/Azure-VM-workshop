// This file contains custom policy definitions

targetScope = 'subscription'

var winAmaName = 'Configure Azure Monitor Agent On Windows VM with system-assigned managed identity'
resource winAma 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: guid(winAmaName)
  properties: {
    displayName: winAmaName
    policyType: 'Custom'
    mode: 'Indexed'
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy.'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      listOfWindowsImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Additional Virtual Machine Images'
          description: 'List of virtual machine images that have supported Windows OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
        }
        defaultValue: []
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Compute/imageId'
                in: '[parameters(\'listOfWindowsImageIdToInclude\')]'
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServer'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2008-R2-SP1*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2012-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2016-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2019-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2022-*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServerSemiAnnual'
                  }
                  {
                    field: 'Microsoft.Compute/imageSKU'
                    in: [
                      'Datacenter-Core-1709-smalldisk'
                      'Datacenter-Core-1709-with-Containers-smalldisk'
                      'Datacenter-Core-1803-with-Containers-smalldisk'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServerHPCPack'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServerHPCPack'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftSQLServer'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2022'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2022-BYOL'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2019'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2019-BYOL'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2016'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2016-BYOL'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2012R2'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2012R2-BYOL'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftRServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'MLServer-WS2016'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftVisualStudio'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'VisualStudio'
                      'Windows'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftDynamicsAX'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Dynamics'
                  }
                  {
                    field: 'Microsoft.Compute/imageSKU'
                    equals: 'Pre-Req-AX7-Onebox-U8'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'microsoft-ads'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'windows-data-science-vm'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsDesktop'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Windows-10'
                  }
                ]
              }
            ]
          }
          {
            field: 'identity.type'
            contains: 'SystemAssigned'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Compute/virtualMachines/extensions'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'AzureMonitorWindowsAgent'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Microsoft.Azure.Monitor'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/provisioningState'
                equals: 'Succeeded'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  vmName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {
                  extensionName: 'AzureMonitorWindowsAgent'
                  extensionPublisher: 'Microsoft.Azure.Monitor'
                  extensionType: 'AzureMonitorWindowsAgent'
                  extensionTypeHandlerVersion: '1.1'
                }
                resources: [
                  {
                    name: '[concat(parameters(\'vmName\'), \'/\', variables(\'extensionName\'))]'
                    type: 'Microsoft.Compute/virtualMachines/extensions'
                    location: '[parameters(\'location\')]'
                    apiVersion: '2019-07-01'
                    properties: {
                      publisher: '[variables(\'extensionPublisher\')]'
                      type: '[variables(\'extensionType\')]'
                      typeHandlerVersion: '[variables(\'extensionTypeHandlerVersion\')]'
                      autoUpgradeMinorVersion: true
                      enableAutomaticUpgrade: true
                    }
                  }
                ]
              }
              parameters: {
                vmName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

var winDcrName = 'Configure Windows Virtual Machines to be associated with a Data Collection Rule'
resource winDcr 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: guid(winDcrName)
  properties: {
    displayName: winDcrName
    policyType: 'Custom'
    mode: 'Indexed'
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy.'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      listOfWindowsImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Optional: List of virtual machine images that have supported Windows OS to add to scope'
          description: 'Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
        }
        defaultValue: []
      }
      dcrResourceId: {
        type: 'String'
        metadata: {
          displayName: 'Data Collection Rule Resource Id or Data Collection Endpoint Resource Id'
          description: 'Resource Id of the Data Collection Rule or the Data Collection Endpoint to be applied on the Linux machines in scope.'
          portalReview: 'true'
        }
      }
      resourceType: {
        type: 'String'
        metadata: {
          displayName: 'Resource Type'
          description: 'Either a Data Collection Rule (DCR) or a Data Collection Endpoint (DCE)'
          portalReview: 'true'
        }
        allowedValues: [
          'Microsoft.Insights/dataCollectionRules'
          'Microsoft.Insights/dataCollectionEndpoints'
        ]
        defaultValue: 'Microsoft.Insights/dataCollectionRules'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Compute/imageId'
                in: '[parameters(\'listOfWindowsImageIdToInclude\')]'
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServer'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2008-R2-SP1*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2012-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2016-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2019-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '2022-*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServerSemiAnnual'
                  }
                  {
                    field: 'Microsoft.Compute/imageSKU'
                    in: [
                      'Datacenter-Core-1709-smalldisk'
                      'Datacenter-Core-1709-with-Containers-smalldisk'
                      'Datacenter-Core-1803-with-Containers-smalldisk'
                      'Datacenter-Core-1809-with-Containers-smalldisk'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsServerHPCPack'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'WindowsServerHPCPack'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftSQLServer'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2016'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2016-BYOL'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2012R2'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '*-WS2012R2-BYOL'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftRServer'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'MLServer-WS2016'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftVisualStudio'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'VisualStudio'
                      'Windows'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftDynamicsAX'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Dynamics'
                  }
                  {
                    field: 'Microsoft.Compute/imageSKU'
                    equals: 'Pre-Req-AX7-Onebox-U8'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'microsoft-ads'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'windows-data-science-vm'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'MicrosoftWindowsDesktop'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Windows-10'
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Insights/dataCollectionRuleAssociations'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
            '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          evaluationDelay: 'AfterProvisioning'
          existenceCondition: {
            anyOf: [
              {
                field: 'Microsoft.Insights/dataCollectionRuleAssociations/dataCollectionRuleId'
                equals: '[parameters(\'dcrResourceId\')]'
              }
              {
                field: 'Microsoft.Insights/dataCollectionRuleAssociations/dataCollectionEndpointId'
                equals: '[parameters(\'dcrResourceId\')]'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  dcrResourceId: {
                    type: 'string'
                  }
                  resourceType: {
                    type: 'string'
                  }
                }
                variables: {
                  dcrAssociationName: '[concat(\'assoc-\', uniqueString(concat(parameters(\'resourceName\'), parameters(\'dcrResourceId\'))))]'
                  dceAssociationName: 'configurationAccessEndpoint'
                  dcrResourceType: 'Microsoft.Insights/dataCollectionRules'
                  dceResourceType: 'Microsoft.Insights/dataCollectionEndpoints'
                }
                resources: [
                  {
                    condition: '[equals(parameters(\'resourceType\'), variables(\'dcrResourceType\'))]'
                    name: '[variables(\'dcrAssociationName\')]'
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                    apiVersion: '2021-04-01'
                    properties: {
                      dataCollectionRuleId: '[parameters(\'dcrResourceId\')]'
                    }
                    scope: '[concat(\'Microsoft.Compute/virtualMachines/\', parameters(\'resourceName\'))]'
                  }
                  {
                    condition: '[equals(parameters(\'resourceType\'), variables(\'dceResourceType\'))]'
                    name: '[variables(\'dceAssociationName\')]'
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                    apiVersion: '2021-04-01'
                    properties: {
                      dataCollectionEndpointId: '[parameters(\'dcrResourceId\')]'
                    }
                    scope: '[concat(\'Microsoft.Compute/virtualMachines/\', parameters(\'resourceName\'))]'
                  }
                ]
              }
              parameters: {
                resourceName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                dcrResourceId: {
                  value: '[parameters(\'dcrResourceId\')]'
                }
                resourceType: {
                  value: '[parameters(\'resourceType\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}


var nameLinuxAma = 'Configure Azure Monitor Agent On Linux VM with system-assigned managed identity'
resource linuxAma 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: guid(nameLinuxAma)
  properties: {
    displayName: nameLinuxAma
    policyType: 'Custom'
    mode: 'Indexed'
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy.'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      listOfLinuxImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Additional Virtual Machine Images'
          description: 'List of virtual machine images that have supported Linux OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
        }
        defaultValue: []
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            field: 'identity.type'
            contains: 'SystemAssigned'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Compute/imageId'
                in: '[parameters(\'listOfLinuxImageIdToInclude\')]'
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'RedHat'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'RHEL'
                      'RHEL-ARM64'
                      'RHEL-BYOS'
                      'RHEL-HA'
                      'RHEL-SAP'
                      'RHEL-SAP-APPS'
                      'RHEL-SAP-HA'
                    ]
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'rhel-lvm7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'rhel-lvm8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'SUSE'
                  }
                  {
                    anyOf: [
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'SLES'
                              'SLES-HPC'
                              'SLES-HPC-Priority'
                              'SLES-SAP'
                              'SLES-SAP-BYOS'
                              'SLES-Priority'
                              'SLES-BYOS'
                              'SLES-SAPCAL'
                              'SLES-Standard'
                            ]
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '12*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '15*'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: 'sles-12*'
                              }
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: 'sles-15*'
                              }
                            ]
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            in: [
                              'gen1'
                              'gen2'
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Canonical'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        equals: 'UbuntuServer'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '0001-com-ubuntu-server-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '0001-com-ubuntu-pro-*'
                      }
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '14.04.0-lts'
                      '14.04.1-lts'
                      '14.04.2-lts'
                      '14.04.3-lts'
                      '14.04.4-lts'
                      '14.04.5-lts'
                      '16_04_0-lts-gen2'
                      '16_04-lts-gen2'
                      '16.04-lts'
                      '16.04.0-lts'
                      '18_04-lts-arm64'
                      '18_04-lts-gen2'
                      '18.04-lts'
                      '20_04-lts-arm64'
                      '20_04-lts-gen2'
                      '20_04-lts'
                      '22_04-lts-gen2'
                      '22_04-lts'
                      'pro-16_04-lts-gen2'
                      'pro-16_04-lts'
                      'pro-18_04-lts-gen2'
                      'pro-18_04-lts'
                      'pro-20_04-lts-gen2'
                      'pro-20_04-lts'
                      'pro-22_04-lts-gen2'
                      'pro-22_04-lts'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Oracle'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Oracle-Linux'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'OpenLogic'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'CentOS'
                      'Centos-LVM'
                      'CentOS-SRIOV'
                    ]
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '6*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'cloudera'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'cloudera-centos-os'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: '7*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'almalinux'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'almalinux'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: '8*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'ctrliqinc1648673227698'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    like: 'rocky-8*'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: 'rocky-8*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'credativ'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'Debian'
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    equals: '9'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Debian'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'debian-10'
                      'debian-11'
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '10'
                      '10-gen2'
                      '11'
                      '11-gen2'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'microsoftcblmariner'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'cbl-mariner'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '1-gen2'
                      'cbl-mariner-1'
                      'cbl-mariner-2'
                      'cbl-mariner-2-arm64'
                      'cbl-mariner-2-gen2'
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Compute/virtualMachines/extensions'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
          ]
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/type'
                equals: 'AzureMonitorLinuxAgent'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/publisher'
                equals: 'Microsoft.Azure.Monitor'
              }
              {
                field: 'Microsoft.Compute/virtualMachines/extensions/provisioningState'
                equals: 'Succeeded'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  vmName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                variables: {
                  extensionName: 'AzureMonitorLinuxAgent'
                  extensionPublisher: 'Microsoft.Azure.Monitor'
                  extensionType: 'AzureMonitorLinuxAgent'
                  extensionTypeHandlerVersion: '1.12'
                }
                resources: [
                  {
                    name: '[concat(parameters(\'vmName\'), \'/\', variables(\'extensionName\'))]'
                    type: 'Microsoft.Compute/virtualMachines/extensions'
                    location: '[parameters(\'location\')]'
                    apiVersion: '2019-07-01'
                    properties: {
                      publisher: '[variables(\'extensionPublisher\')]'
                      type: '[variables(\'extensionType\')]'
                      typeHandlerVersion: '[variables(\'extensionTypeHandlerVersion\')]'
                      autoUpgradeMinorVersion: true
                      enableAutomaticUpgrade: true
                    }
                  }
                ]
              }
              parameters: {
                vmName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

var linuxDcrName = 'Configure Linux Virtual Machines to be associated with a Data Collection Rule'
resource linuxDcr 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: guid(linuxDcrName)
  properties: {
    displayName: linuxDcrName
    policyType: 'Custom'
    mode: 'Indexed'
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy.'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      listOfLinuxImageIdToInclude: {
        type: 'Array'
        metadata: {
          displayName: 'Additional Linux Machine Images'
          description: 'List of machine images that have supported Linux OS to add to scope. Example values: \'/subscriptions/<subscriptionId>/resourceGroups/YourResourceGroup/providers/Microsoft.Compute/images/ContosoStdImage\''
        }
        defaultValue: []
      }
      dcrResourceId: {
        type: 'String'
        metadata: {
          displayName: 'Data Collection Rule Resource Id or Data Collection Endpoint Resource Id'
          description: 'Resource Id of the Data Collection Rule or the Data Collection Endpoint to be applied on the Linux machines in scope.'
          portalReview: 'true'
        }
      }
      resourceType: {
        type: 'String'
        metadata: {
          displayName: 'Resource Type'
          description: 'Either a Data Collection Rule (DCR) or a Data Collection Endpoint (DCE)'
          portalReview: 'true'
        }
        allowedValues: [
          'Microsoft.Insights/dataCollectionRules'
          'Microsoft.Insights/dataCollectionEndpoints'
        ]
        defaultValue: 'Microsoft.Insights/dataCollectionRules'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Compute/imageId'
                in: '[parameters(\'listOfLinuxImageIdToInclude\')]'
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'RedHat'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'RHEL'
                      'RHEL-ARM64'
                      'RHEL-BYOS'
                      'RHEL-HA'
                      'RHEL-SAP'
                      'RHEL-SAP-APPS'
                      'RHEL-SAP-HA'
                    ]
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'rhel-lvm7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: 'rhel-lvm8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'SUSE'
                  }
                  {
                    anyOf: [
                      {
                        allOf: [
                          {
                            field: 'Microsoft.Compute/imageOffer'
                            in: [
                              'SLES'
                              'SLES-HPC'
                              'SLES-HPC-Priority'
                              'SLES-SAP'
                              'SLES-SAP-BYOS'
                              'SLES-Priority'
                              'SLES-BYOS'
                              'SLES-SAPCAL'
                              'SLES-Standard'
                            ]
                          }
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '12*'
                              }
                              {
                                field: 'Microsoft.Compute/imageSku'
                                like: '15*'
                              }
                            ]
                          }
                        ]
                      }
                      {
                        allOf: [
                          {
                            anyOf: [
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: 'sles-12*'
                              }
                              {
                                field: 'Microsoft.Compute/imageOffer'
                                like: 'sles-15*'
                              }
                            ]
                          }
                          {
                            field: 'Microsoft.Compute/imageSku'
                            in: [
                              'gen1'
                              'gen2'
                            ]
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Canonical'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        equals: 'UbuntuServer'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '0001-com-ubuntu-server-*'
                      }
                      {
                        field: 'Microsoft.Compute/imageOffer'
                        like: '0001-com-ubuntu-pro-*'
                      }
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '14.04.0-lts'
                      '14.04.1-lts'
                      '14.04.2-lts'
                      '14.04.3-lts'
                      '14.04.4-lts'
                      '14.04.5-lts'
                      '16_04_0-lts-gen2'
                      '16_04-lts-gen2'
                      '16.04-lts'
                      '16.04.0-lts'
                      '18_04-lts-arm64'
                      '18_04-lts-gen2'
                      '18.04-lts'
                      '20_04-lts-arm64'
                      '20_04-lts-gen2'
                      '20_04-lts'
                      '22_04-lts-gen2'
                      '22_04-lts'
                      'pro-16_04-lts-gen2'
                      'pro-16_04-lts'
                      'pro-18_04-lts-gen2'
                      'pro-18_04-lts'
                      'pro-20_04-lts-gen2'
                      'pro-20_04-lts'
                      'pro-22_04-lts-gen2'
                      'pro-22_04-lts'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Oracle'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'Oracle-Linux'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'OpenLogic'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'CentOS'
                      'Centos-LVM'
                      'CentOS-SRIOV'
                    ]
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '6*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '7*'
                      }
                      {
                        field: 'Microsoft.Compute/imageSku'
                        like: '8*'
                      }
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'cloudera'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'cloudera-centos-os'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: '7*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'almalinux'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'almalinux'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: '8*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'ctrliqinc1648673227698'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    like: 'rocky-8*'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    like: 'rocky-8*'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'credativ'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'Debian'
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    equals: '9'
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'Debian'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    in: [
                      'debian-10'
                      'debian-11'
                    ]
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '10'
                      '10-gen2'
                      '11'
                      '11-gen2'
                    ]
                  }
                ]
              }
              {
                allOf: [
                  {
                    field: 'Microsoft.Compute/imagePublisher'
                    equals: 'microsoftcblmariner'
                  }
                  {
                    field: 'Microsoft.Compute/imageOffer'
                    equals: 'cbl-mariner'
                  }
                  {
                    field: 'Microsoft.Compute/imageSku'
                    in: [
                      '1-gen2'
                      'cbl-mariner-1'
                      'cbl-mariner-2'
                      'cbl-mariner-2-arm64'
                      'cbl-mariner-2-gen2'
                    ]
                  }
                ]
              }
            ]
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Insights/dataCollectionRuleAssociations'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
            '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
          ]
          evaluationDelay: 'AfterProvisioning'
          existenceCondition: {
            anyOf: [
              {
                field: 'Microsoft.Insights/dataCollectionRuleAssociations/dataCollectionRuleId'
                equals: '[parameters(\'dcrResourceId\')]'
              }
              {
                field: 'Microsoft.Insights/dataCollectionRuleAssociations/dataCollectionEndpointId'
                equals: '[parameters(\'dcrResourceId\')]'
              }
            ]
          }
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  dcrResourceId: {
                    type: 'string'
                  }
                  resourceType: {
                    type: 'string'
                  }
                }
                variables: {
                  dcrAssociationName: '[concat(\'assoc-\', uniqueString(concat(parameters(\'resourceName\'), parameters(\'dcrResourceId\'))))]'
                  dceAssociationName: 'configurationAccessEndpoint'
                  dcrResourceType: 'Microsoft.Insights/dataCollectionRules'
                  dceResourceType: 'Microsoft.Insights/dataCollectionEndpoints'
                }
                resources: [
                  {
                    condition: '[equals(parameters(\'resourceType\'), variables(\'dcrResourceType\'))]'
                    name: '[variables(\'dcrAssociationName\')]'
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                    apiVersion: '2021-04-01'
                    properties: {
                      dataCollectionRuleId: '[parameters(\'dcrResourceId\')]'
                    }
                    scope: '[concat(\'Microsoft.Compute/virtualMachines/\', parameters(\'resourceName\'))]'
                  }
                  {
                    condition: '[equals(parameters(\'resourceType\'), variables(\'dceResourceType\'))]'
                    name: '[variables(\'dceAssociationName\')]'
                    type: 'Microsoft.Insights/dataCollectionRuleAssociations'
                    apiVersion: '2021-04-01'
                    properties: {
                      dataCollectionEndpointId: '[parameters(\'dcrResourceId\')]'
                    }
                    scope: '[concat(\'Microsoft.Compute/virtualMachines/\', parameters(\'resourceName\'))]'
                  }
                ]
              }
              parameters: {
                resourceName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                dcrResourceId: {
                  value: '[parameters(\'dcrResourceId\')]'
                }
                resourceType: {
                  value: '[parameters(\'resourceType\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

output winAmaId string = winAma.id
output winDcrId string = winDcr.id
output linuxAmaId string = linuxAma.id
output linuxDcrId string = linuxDcr.id
