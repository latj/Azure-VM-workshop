# Azure Policies

The templates in this folder creates deploys policy assignments to the current subscription.
They also create a user assigned managed identity and assigns it the Azure RBAC [Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles) role on the subscription. This managed identity are used by policies to carry out `deployIfNotExists` actions

## Deploy the identity and policy assignments

```powershell
New-AzSubscriptionDeployment -Name "policy" -Location "SwedenCentral" -TemplateFile main.bicep -TemplateParameterFile main.parameters.json
```
