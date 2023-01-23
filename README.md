# Azure-VM-workshop

## Prerequisites

1. An Azure subscription with at least the [Contributor](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles) role assigned
2. [Powershell 7](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.3)
3. [Azure Powershell Module](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps?view=azps-9.3.0)
4. [Bicep for powershell](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/install#azure-powershell)

### Log into to Azure

```powershell
Connect-AzAccount
```

### Select the correct subscription

```powershell
Select-AzSubscription -SubscriptionName "NameOfMySubscription"
```

## Step 1: Deploy Policy assignments

For detailed instructions please see [policies/README.md](policies/README.md)

## Step 2: Deploy the network

For detailed instructions please see [network/README.md](network/README.md)

## Step 3: Deploy a virtual machine

For detailed instructions please see [vm/README.md](vm/README.md)

## Clean Up

1. Remove all resource groups created
2. Remove policy assignments from subscription
3. Remove orphaned role assignments on subscription