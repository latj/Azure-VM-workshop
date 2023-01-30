# Azure-VM-workshop

## Prerequisites

1. An Azure subscription with the [Owner](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner)

The instructions in the lab uses [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/) to interact with Azure (for example deploying [Bicep](https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview?tabs=bicep) templates). All commands can be run from [Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/overview), meaning there is no need to install any software except a web browser locally.

## Configure Azure Cloud Shell

[Azure Cloud Shell](https://learn.microsoft.com/en-us/azure/cloud-shell/overview) is an interactive, authenticated, browser-accessible shell for managing Azure resources. All the lab instructions in this document can be run from the cloud shell , directly in your browser. There is no need to install anything locally on your computer.

**To access the cloud shell please follow those step:**

1. Navigate to https://portal.azure.com
2. Log in
3. Launch cloud shell from the top bar menu in the portal
![image](https://learn.microsoft.com/en-us/azure/cloud-shell/media/overview/portal-launch-icon.png)
4. If it is the first time you launch cloud shell you will need to configure it with a default runtime and [a storage account](https://learn.microsoft.com/en-us/azure/cloud-shell/persisting-shell-storage)
   - Select "Powershell" or "Bash" as your default runtime. The instructions in this document work with both.
   - Provision the storage account in your lab subscription with the default settings

Once cloud shell is loaded you can select your runtime (either `bash` och `powershell`) from the drop down list at the top.

**Make sure that the correct subscription is selected** by examining the output of the following command

```powershell
az account show --query name
```

If you need to change subscription, please run the following command

```powershell
az account set --subscription "NameOfMySubscription"
```

## Clone the repository content

The content of this repository can be cloned with the following command.

```powershell
git clone https://github.com/latj/Azure-VM-workshop.git
```

You can then change into the repository folder with the `cd` command

```powershell
cd Azure-VM-workshop
```

## View and edit files

To view and edit the files you can use your favorite editor. If you are running Azure Cloud Shell it comes with an integrated file editor built called [Azure Cloud Shell Editor](https://learn.microsoft.com/en-us/azure/cloud-shell/using-cloud-shell-editor)

### Opening the editor

For simple file creation and editing, launch the editor by running `code .` in the Cloud Shell terminal. This action opens the editor with your active working directory set in the terminal.

To directly open a file for quick editing, run `code <filename>` to open the editor without the file explorer.

Select the `{}` icon from the toolbar to open the editor and default the file explorer to the `/home/<user>` directory.

### Closing the editor

To close the editor, open the `...` action panel in the top right of the editor and select Close editor.

### A useful few shortcuts

- Save: `CTRL`+ `S`
- Close: `CTRL` + `Q`
- Open file (while inside the editor): `CTRL` + `P`


## Step 1: Deploy the network

Before any virtual machines can be deployed there needs to be a network to deploy them into. The folder [network/](network/) contains a set of bicep templates that deploy a simple network and an [Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/bastion-overview) host that can be used to deploy the machines.

The network can be deployed using the following command

```powershell
az deployment sub create --location "SwedenCentral" --name "network" --template-file network/main.bicep --parameters @network/main.parameters.json
```

## Step 2: Deploy Monitoring Capabilities

To collect telemetry data from virtual machines a [Log analytics workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-workspace-overview) and [data collection rules](https://learn.microsoft.com/en-us/azure/azure-monitor/essentials/data-collection-rule-overview) are needed. In this lab series we will deploy a central log analytics workspace which multiple virtual machines can use to send their logs to.

The folder [monitoring/](monitoring/) contains a set of bicep templates that deploys a log analytics workspace along with a few example data collection rules. They can be deployed using the following command:

```powershell
az deployment sub create --location "SwedenCentral" --name "monitor" --template-file monitoring/main.bicep --parameters @monitoring/main.parameters.json
```

## Step 3: Deploy a virtual machine

The folder [vm/](vm/) contains templates to deploy and configure [virtual machines](https://learn.microsoft.com/en-us/azure/virtual-machines/overview).

### 3.1. Deploy a plain windows virtual machine

The first step is to deploy a plain virtual machine. To create a virtual machine with an [OS disk](https://learn.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview) and a [network interface card](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface?tabs=network-interface-portal) connected to the previously created network please use the below command

```powershell
az deployment sub create --location "SwedenCentral" --name "vm" --template-file vm/main.bicep --parameters @vm/main.parameters.json 
```

### 3.2 Enable Disk Encryption on the VM

[Azure Disk Encryption](https://learn.microsoft.com/en-us/azure/virtual-machines/extensions/azure-disk-enc-windows) uses BitLocker to provide full disk encryption on Azure virtual machines running Windows. This solution is integrated with [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/overview) to manage disk encryption keys and secrets.

By passing the parameter `-diskEncryption $true` to the deployment of the `main.bicep` file the content of `diskEncryption.bicep` is deployed in addition to what is inside the `vm.bicep` file. This will create a key in a key vault which will be used to encrypt the disks on the VM using  Azure Disk Encryption

```powershell
az deployment sub create --location "SwedenCentral" --name "vmWithDiskEncryption" --template-file vm/main.bicep --parameters @vm/main.parameters.json --parameters enableDiskEncryption='true'
```

### 3.3 Deploy a data collection rule

// TODO: Instructions for enabling VM-Insights and DCR manually

## Step 4: Manage virtual machines at scale using Azure Policy

In step 3.3 a data collection rule was created and attached to the VM by modifying the bicep template. While this works and is a valid approach it can become error prone to require everyone that deploys virtual machines to configure data collection rules correctly. Instead the rules can be applied automatically by [Azure policy](https://learn.microsoft.com/en-us/azure/governance/policy/overview) to ensure that the same set of basic telemetry data is collected from all VM's deployed in a subscription.

### Step 4.2: Create a data collection rule using Azure Policy

//TODO: THIS DOES NOT WORK IN SWEDEN CENTRAL, SINCE THE BUILT IN POLICIES DOES NOT TARGET RESOURCES THERE
// REWRITE THIS USING CUSTOM POLICIES - IT WILL BE A GOOD DEMONSTRATION

To enable the policy on the subscription run the following command

```powershell
az deployment sub create --location "SwedenCentral" --name "policyWithDataCollectionRule" --template-file policies/main.bicep --parameters @policies/main.parameters.json enableDataCollectionPolicy='true'
```

As we previously deployed and configured a virtual machine with VM Insights enabled, let's remove that Virtual Machine and redeploy without VM Insights. This should trigger the policy to add VM-Insights

To remove the resource group containing the Virtual Machine, please run

```powershell
az group delete --name contoso-vm-rg
```

to redeploy the machine, please run

```powershell
az deployment sub create --location "SwedenCentral" --name "vmWithDiskEncryption" --template-file vm/main.bicep --parameters @main.parameters.json enableDiskEncryption='true'
```

Once the new virtual machine has been created, navigate to it in the Azure portal and select "Insights" from the "Monitoring" Section in the left pane. It will say that Insights is not yet configured. In a few minutes when the policy has executed it should be automatically configured and display data

### Step 4.3: Enable Azure backup using Azure policy

Also [Azure backup](https://learn.microsoft.com/en-us/azure/backup/backup-overview) can be enabled using Azure policy

To enable the policy on the subscription run the following command

```powershell
az deployment sub create --location "SwedenCentral" --name "policyWithBackup" --template-file policies/main.bicep --parameters @policies/main.parameters.json enableBackupPolicy='true'
```

The backup policy is configured to target all virtual machines with the tag `backup` set to `yes`. The tag value can be set to yes either through the portal or by re-running the deployment of the VM with the tag `enableBackupTag` set to true:

```powershell
az deployment sub create --location "SwedenCentral" --name "vmWithBackupTag" --template-file vm/main.bicep --parameters @vm/main.parameters.json enableBackupTag='true'
```

Once the policy runs it will create a new [Service Recovery Vault](https://learn.microsoft.com/en-us/azure/backup/backup-azure-recovery-services-vault-overview) in the same resource group as the virtual machine and configure a daily backup of the machine to the vault

## Clean Up

1. Remove all resource groups created
   - Remove Backup Vault
2. Remove policy assignments from subscription
3. Remove orphaned role assignments on subscription