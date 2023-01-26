# Network

The templates in this folder contains the virtual network

## Deploy the network

```powershell
New-AzSubscriptionDeployment -Name "network" -Location "SwedenCentral" -TemplateFile main.bicep -TemplateParameterFile azuredeploy.parameters.json -Verbose
```
