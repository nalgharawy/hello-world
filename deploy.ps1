<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.  

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>

param(
 [Parameter(Mandatory=$True)]
 [string]
 $Countrycode,

 
 [string]
 $subscriptionId ="bc4314ad-46b4-473e-9489-e9e29c406d3a",

 #[Parameter(Mandatory=$True)]
 [string]
 $resourceGroupName =  "RG-UNI-$Countrycode",
 
 [string]
 $resourceGroupLocation = "West Europe",

 #[Parameter(Mandatory=$True)]
 [string]
 $deploymentName = "$Countrycode-prim01",

 [string]
 $templateFilePath = "c:\t\template.json",

 [string]
 $parametersFilePath = "c:\t\parameters.json",
 
 [string]  
 $StorAcct_saunixxxxprimeroprem_name = "StorAcctsauni$Countrycode" + "primeroprem",

 [string]  
 $StorAcct_saunixxxxprimero_name = "StorAcctsauni$Countrycode" + "primero" 

 )

<#
.SYNOPSIS
    Registers RPs
#>


Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace -Force;
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
#Login-AzureRmAccount;

# select subscription
Get-AzureRmSubscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Register RPs
$resourceProviders = @("microsoft.compute","microsoft.network","microsoft.storage");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue 
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# Start the deployment
Write-Host "Starting deployment...";
#if(Test-Path $parametersFilePath) {
 #   New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath -TemplateParameterFile $parametersFilePath;
#} else {
$StorAcct_saunixxxxprimeroprem_name = $StorAcct_saunixxxxprimeroprem_name.ToLower()
$StorAcct_saunixxxxprimero_name = $StorAcct_saunixxxxprimero_name.ToLower()
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateFile $templateFilePath;
