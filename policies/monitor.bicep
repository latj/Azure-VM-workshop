@description('Base prefix of all resources')
param baseName string

@description('Location for all resources.')
param location string = resourceGroup().location

resource dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: '${baseName}-default-dcr'
  location: location
  kind: 'Windows'
  properties: {
    dataSources: {
      performanceCounters: [
        {
          counterSpecifiers: [
            '\\Memory\\% Committed Bytes In Use'
            '\\Memory\\Available Bytes'
            '\\Memory\\Committed Bytes'
            '\\Memory\\Cache Bytes'
            '\\Memory\\Pool Paged Bytes'
            '\\Memory\\Pool Nonpaged Bytes'
            '\\Memory\\Pages/sec'
            '\\Memory\\Page Faults/sec'
          ]
          name: 'perfCounterDataSource10'
          samplingFrequencyInSeconds: 10
          streams: [
            'Microsoft-InsightsMetrics'
          ]
        }
      ]
    }
    destinations: {
      azureMonitorMetrics: {
        name: 'azureMonitorMetrics-default'
      }
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

output dcrId string = dcr.id
