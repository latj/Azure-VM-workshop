@description('Base prefix of all resources')
param baseName string 

@description('Location for all resources')
param location string = resourceGroup().location

@description('Vm to apply encryption on')
param vmName string

@description('Vm to apply encryption on')
param logAnalyticsName string

resource vm 'Microsoft.Compute/virtualMachines@2021-03-01' existing = {
  name: vmName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: logAnalyticsName
}

resource windowsAgent 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'AzureMonitorWindowsAgent'
  parent: vm
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
  }
}

resource dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: '${baseName}-default-dcr'
  location: location
  kind: 'Windows'
  properties: {
    dataSources: {
      performanceCounters: [
        {
          counterSpecifiers: [
            '\\VmInsights\\DetailedMetrics'
          ]
          name: 'VMInsightsPerfCounters'
          samplingFrequencyInSeconds: 60
          streams: [
            'Microsoft-InsightsMetrics'
          ]
        }
      ]
    }
    destinations: {
      logAnalytics: [{
        workspaceResourceId: logAnalyticsWorkspace.id
        name: 'azureMonitorMetrics-default'
      }]
    }
    dataFlows: [{ 
      streams: [
        'Microsoft-InsightsMetrics'
      ]
      destinations: [
        'azureMonitorMetrics-default'
      ]
    }]
  }
}

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = {
  name: '${baseName}-vminsights-dcr-associationName'
  scope: vm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this virtual machine.'
    dataCollectionRuleId: dcr.id
  }
}
