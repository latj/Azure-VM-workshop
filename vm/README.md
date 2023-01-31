# Azure Virtual Machine

The templates in this folder deploys an Azure Virtual Machine

## Deploy the virtual machine

```powershell
az deployment sub create --location "SwedenCentral" --name "vm" --template-file main.bicep --parameters @main.parameters.json enableBackupTag='true' enableDiskEncryption='true'
```
