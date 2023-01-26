# Azure Virtual Machine

The templates in this folder deploys an Azure Virtual Machine

## Deploy the virtual machine

```powershell
New-AzSubscriptionDeployment -Name "vm" -Location "SwedenCentral" -TemplateFile main.bicep -TemplateParameterFile main.parameters.json
```
