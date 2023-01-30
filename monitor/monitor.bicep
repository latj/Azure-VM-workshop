// This file deploys monitoring resources into the monitoring resource group
// - A log analytics workspace
// - A data collection rule

@description('Base prefix of all resources')
param baseName string

@description('Location for all resources.')
param location string = resourceGroup().location

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: '${baseName}-logs'
  location: location
  properties: {
    sku: {
      name: 'standalone'
    }
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

//// OUTPUTS

output dcrId string = dcr.id
output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id
