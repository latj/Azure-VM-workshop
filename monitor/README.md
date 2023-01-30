# Monitoring

The templates in this folder creates and deploys a [log analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview) as well as a few data collection rules.

## Deploy the identity and policy assignments

```powershell
az deployment sub create --location "SwedenCentral" --name "monitor" --template-file main.bicep --parameters @main.parameters.json
```
