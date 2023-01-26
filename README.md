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

## Step 4: Manage virtual machines at scale using Azure Policy

In step 3 a data collection rule was created and attached to the VM by modifying the bicep template. While this works and is a valid approach it can become error prone to require everyone that deploys virtual machines to configure data collection rules correctly. Instead the rules can be applied automatically by Azure policy to ensure that the same set of basic telemetry data is collected from all VM's deployed in a subscription.

### Step 4.1: Create a data collection rule using Azure Policy

//TODO: START BY REMOVING THE PREVIOUSLY ATTACHED DATA COLLECTION RULE

To enable the policy on the subscription run the following command

```powershell
New-AzSubscriptionDeployment -Name "policyWithDataCollectionRule" -Location "SwedenCentral" -TemplateFile policies/main.bicep -TemplateParameterFile policies/main.parameters.json -enableDataCollectionPolicy $true
```

//TODO: Does not seem to work (Cannot se the DCR on the machine)

### Step 4.2: Enable Azure backup using Azure policy

Also Azure backup can be enabled using Azure policy

To enable the policy on the subscription run the following command

```powershell
New-AzSubscriptionDeployment -Name "policyWithBackup" -Location "SwedenCentral" -TemplateFile policies/main.bicep -TemplateParameterFile policies/main.parameters.json -enableBackupPolicy $true
```

The backup policy is configured to target all virtual machines with the tag `backup` set to `yes`. The tag value can be set to yes either through the portal or by re-running the deployment of the VM with the tag `enableBackupTag` set to true:

```powershell
New-AzSubscriptionDeployment -Name "diskEncryption" -Location "SwedenCentral" -TemplateFile vm/main.bicep -TemplateParameterFile vm/main.parameters.json -enableBackupTag $true
```

Once the policy runs it will create a new Service Recovery Vault in the same resource group as the virtual machine and configure a daily backup of the machine to the vault

## Clean Up

1. Remove all resource groups created
2. Remove policy assignments from subscription
3. Remove orphaned role assignments on subscription