# Deploy SQL VM with CRISP components installed and Domain Join

This template deploys one or more SQL VMs, installs all required CRISP components and then joins the machine(s) to the VA domain.
Before you can deploy the template, your program must have been onboarded to Azure and provided with a 3 digit program code. You will also need the name of the resource group, virtual network, and subnet that was provided to your project.

To deploy the template, you will need to provide the following parameters:

- vmName 
- vmSize
- numberOfServersToDeploy
- sqlOSVersion
- sqlStorageDisksCount
- numberOfDataDisks
- dataDiskSizes
- ResourceGroupName
- existingVNETName
- existingVNETResourceGroupName
- subnetName
- keyVaultName
- keyVaultSecretName
- keyVaultResourceGroupName 
- location
- VmAdminUserName
- vmAdminPassword (This will be used as the local admin password) 
- domainUserName (This will be used as the account to join the machine to the domain)
- domainToJoin
- domainGroupToAdd
- ouPath 
- imageSku
- crispComponentURI
- provisioningScriptURI
- vmStartInstancePrefix
