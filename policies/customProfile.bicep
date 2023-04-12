@description('Base prefix of all resources')
param name string 

@description('Location for all resources.')
param location string = resourceGroup().location

@allowed([
  'ApplyAndAutoCorrect'
  'ApplyAndMonitor'
  'Audit'
])
param azureSecurityBaselineAssignmentType string

resource customProfile 'Microsoft.Automanage/configurationProfiles@2022-05-04' = {
  name: name
  location: location
  properties: {
    configuration: {
      'AzureSecurityBaseline/Enable': true
      'AzureSecurityBaseline/AssignmentType': azureSecurityBaselineAssignmentType
    }
  }
}

output outputCustomProfile string = customProfile.id
