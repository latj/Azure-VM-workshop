# Azure Virtual Machine

The templates in this folder deploys an Azure Virtual Machine

## Deploy the virtual machine

The first step is to deploy a plain virtual machine. To create a virtual machine with an OS disk and a Network interface connected to the previously created network please use the below command

```powershell
New-AzSubscriptionDeployment -Name "vm" -Location "SwedenCentral" -TemplateFile main.bicep -TemplateParameterFile main.parameters.json
```

## Deploy disk encryption

[Azure Disk Encryption](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/azure-disk-enc-windows) uses BitLocker to provide full disk encryption on Azure virtual machines running Windows. This solution is integrated with Azure Key Vault to manage disk encryption keys and secrets in your key vault subscription.

By passing the parameter `-diskEncryption $true` to the deployment of the `main.bicep` file the content of `diskEncryption.bicep` is deployed in addition to what is inside the `vm.bicep` file. This will create a key in a key vault which will be used to encrypt the disks on the VM using  Azure Disk Encryption

```powershell
New-AzSubscriptionDeployment -Name "diskEncryption" -Location "SwedenCentral" -TemplateFile main.bicep -TemplateParameterFile main.parameters.json -diskEncryption $true
```
