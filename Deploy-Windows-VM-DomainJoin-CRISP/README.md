# Deploy Domain Joined Windows VM with CRISP

This template deploys one or more Windows VMs (either Server 2012 R2 Datacenter or Server 2016 Datacenter), installs all required CRISP components and then joins the machine(s) to the domain of your choice.
Before you can deploy the template, your program must have been onboarded to Azure and provided with a 3 digit program code. You will also need the name of the resource group, virtual network, and subnet that was provided to your project.

For information on how to use this template, please see https://docs.ec.va.gov/Cloud-Learning/Azure/Deployment/Deploying-A-VA-Windows-VM-To-Azure.html

To deploy the template, you will need to provide the following parameters:

- Location (Can be usgovvirginia, usgovtexas, usgovarizona)
- VM Name (Use the proper naming convention documented @ https://docs.ec.va.gov/Enterprise-Cloud/Microsoft-Azure/Azure-Naming-Standards.html)
- VM Start Instance Suffix (The number at which to begin numbering your VM. Should match the environment, i.e. DEV, PROD)
- VM Size (Default is Standard_D2_v2)
- Windows OS Version (Either 2012-R2-Datacenter or 2016-Datacenter)
- Number of Servers to Deploy
- Resource Group Name
- Existing VNET Name
- Existing VNET Resource Group
- Subnet Name
- Key Vault Name (See internal deployment guide for details)
- Key Vault Secret Name (See internal deployment guide for details)
- Key Vault Resource Group Name (See internal deployment guide for details)
- Key Vault Subscription Id
- VM Admin UserName (Local admin account name. Will be renamed after domain join)
- VM Admin Password 
- Domain To Join (Default is va.gov)
- Domain Group To Add (This will be the name of the domain group provided to your project)
- OU Path (This is the Organizational Unit where the VM will be added when it is joined to the domain)
- CRISP Component URI (Location of the CRISP components. See deployment doc for details)

<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdepartment-of-veterans-affairs%2FAzure-templates%2Fmaster%2FDeploy-Windows-VM-DomainJoin-CRISP%2Fazuredeploy.json" target="_blank">
    <img src="https://azuredeploy.net/AzureGov.png"/>
</a>
