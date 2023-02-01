/*
SUMMARY: Module for installing the custom script extension
AUTHOR/S: JimmyKarlsson112
VERSION: 1.0.0
*/

targetScope = 'resourceGroup'

param vmserver string 
param command string = 'powershell -command \' New-Item -Path "C:\temp\test.txt"-force \' '


resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' existing = {
  name: vmserver
}

resource script 'Microsoft.Compute/virtualMachines/extensions@2021-11-01' = {
  name: 'CustomScriptExtension'
  location: resourceGroup().location
  parent: vm
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: command
    }
  }
}
