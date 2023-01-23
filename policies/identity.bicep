@description('Base prefix of all resources')
param name string 

@description('Location for all resources.')
param location string = resourceGroup().location

resource policyMi 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: name
  location: location
}

output identityId string = policyMi.id
output identityPrincipalId string = policyMi.properties.principalId
