# HubnSpoke-networking

In the following exericise we will create an Hub and Spoke topology over two different subscription. One Subscription will be hub subscription, where central components such as

* Azure Firewall
* Azure Bastion
etc
will be in. 

In the other subscription, we will create our spoke subscription where we will create a Virtual network that will connect to our Hub.


## Deploy Hub

### Create resource groups
Open up Powershell or shell.azure.com and select your hub subscription

```
Select-AzSubscription -SubscriptionName "hubsub"
```

Create resource group firewallpolicy-rg
```
    New-AzResourceGroup -Name "fwpolicy-rg" -Location northeurope
```

Create resource group hub-rg
```
    New-AzResourceGroup -Name "hub-rg" -Location northeurope
```
### Deploy Firewall policy
We will now deploy the Firewall policy object
Navigate to the folder Hub\1-firewallpolicy and run following command

```
    New-AzResourceGroupDeployment -Name "new" -ResourceGroupName "fwpolicy-rg" -TemplateFile .\FWPOLICY\firewallpolicy.bicep -Verbose
```

Take the output firewall id and store that value for next step

### Deploy the hub components
We will now deploy the hub that will deploy different objects, such as Expressroutegateway, firewall, virtual network, azure bastion and route tables. Take the firewallpolicy id value you recieved and update the value on policyid in hub.vnet.bicep file.
Naviagate to the folder Hub\2-DeployHub and run the following command (this will take between 20-30 minutes)

```
    New-AzResourceGroupDeployment -Name "new-hub" -ResourceGroupName "hub-rg" -TemplateFile .\hubvnet.bicep -Verbose
```

Take the output hubvnetID, hubVnetName, GatewayRouteTable and FirewallinternalIP and store them for next step, that will be to deploy a spoke

## Deploy the spoke
We will now deploy the spoke in the other subscription that will connect to the hub thru the use of VNET peering

```
Select-AzSubscription -SubscriptionName "spokesub"
```
Navigate to SPOKE folder and start with updating the following parameters in the Spokesub-azureDeployment.parameters.json file from output from the hub deployment
* GatewayRoutetable
* ConnectionHubVNETName
* ConnectionhubNameRG (hub-rg)
* ConnectionhubNameSubID (value afters /subscriptions/ in hubvnetid)
* VNETpeer1 (complete hubvnetid value)
* FirewallInternalIP

We will now deploy a virtual network that will peer together with the hub.
After that run the following command 

```
    New-AzSubscriptionDeployment -Name "spoke" -Location "northeurope" -TemplateFile .\SPOKE\Main-azureDeployment.bicep -TemplateParameterFile .\SPOKE\Spokesub-azureDeployment.parameters.json -Verbose
```