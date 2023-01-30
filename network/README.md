# Network

The templates in this folder contains the virtual network

## Deploy the network

```powershell
az deployment sub create --location "SwedenCentral" --name "network" --template-file main.bicep --parameters @main.parameters.json
```
