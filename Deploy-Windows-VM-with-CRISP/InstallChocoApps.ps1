param (
        [string]$agentURI
    )
    
function WriteLog {
        Param(
            $message
        )
    
        $timestampedMessage = $("[" + [System.DateTime]::Now + "] " + $message) | % {
            Out-File -InputObject $_ -FilePath '$env:WinDir\Temp\ProvisioningScript.log' -Append
        }
    }
    
WriteLog "Script Begin"
    
WriteLog "Agent URL: $agentURI"
    
Add-Type -AssemblyName System.IO.Compression.FileSystem
    
function unzip {
     param( [string]$ziparchive, [string]$extractpath )
     [System.IO.Compression.ZipFile]::ExtractToDirectory( $ziparchive, $extractpath )
    }
    
$agentsTemp = "C:\Temp\Agents"
    
#Create Temp Directory
New-Item -ItemType Directory -Path $AgentsTemp -Force -Confirm: $false -Verbose
    
#Download Installers Zip File
Invoke-WebRequest -Uri $agentURI -OutFile "$AgentsTemp\agents.zip" -Verbose
    
#Extracting Zip File
unzip "$AgentsTemp\agents.zip" $AgentsTemp
    
#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression $agentsTemp\chocolatey\chocolateyInstall.ps1

$pkgToInstall=Get-ChildItem $agentsTemp | where {$_.name -like '*.nupkg'}

#Install Packages
Set-Location $sagentsTemp
ForEach ($pkg in $pkgToInstall) { 
        WriteLog "Installing Package $pkg.name"
        choco install $pkg.name -y -dv -s . 
        }



