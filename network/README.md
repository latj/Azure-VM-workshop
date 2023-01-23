# Simple networking

## Deploy the network
We will now deploy the network we will deploy Virtual machines to later

```
Select-AzSubscription -SubscriptionName "spokesub"
```

```
    New-AzSubscriptionDeployment -Name "network" -Location "SwedenCentral" -TemplateFile main.bicep -TemplateParameterFile azuredeploy.parameters.json -Verbose
```