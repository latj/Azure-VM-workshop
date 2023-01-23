# Simple networking

## Deploy the network
We will now deploy the network we will deploy Virtual machines to later

```powershell
Select-AzSubscription -SubscriptionName "spokesub"
```

```powershell
New-AzSubscriptionDeployment -Name "network" -Location "SwedenCentral" -TemplateFile main.bicep -TemplateParameterFile azuredeploy.parameters.json -Verbose
```