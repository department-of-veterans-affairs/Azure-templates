param (
    
    [string]$agentURI

)

$agentsTemp = "C:\Temp\Agents"

#Create Temp Directory
New-Item -ItemType Directory -Path $AgentsTemp -Force -Confirm: $false -Verbose

#Download Installers Zip File
Invoke-WebRequest -Uri $agentURI -OutFile "$AgentsTemp\agents.zip" -Verbose

#Extracting Zip File
Try{
Expand-Archive -Path "$AgentsTemp\agents.zip" -DestinationPath $AgentsTemp -Force
}
Catch{
Add-Type -assembly "system.io.compression.filesystem"
[io.compression.zipfile]::ExtractToDirectory("$AgentsTemp\agents.zip", $agentsTemp)
}

#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression C:\Temp\Agents\chocolatey\chocolateyInstall.ps1

#Assign Packages to Install
$Packages = 'bigfixagent.9.2.6.94.nupkg', `
    'encasesafe.7.07.nupkg', `
    'safenet.5.1.88.0.nupkg', `
    'wincollect.7.2.5.nupkg', `
    'McAfeeAgent.4.8.0.2001.nupkg'

#Install Packages
Set-Location C:\Temp\Agents
ForEach ($PackageName in $Packages)
{choco install $PackageName -y -dv -s .}

#Reboot
Restart-Computer
