param (
        
        [string]$agentURI
    )
    
    function WriteLog
    {
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
    Invoke-Expression C:\Temp\Agents\chocolatey\chocolateyInstall.ps1
    
    #Assign Packages to Install
    $Packages = 'bigfixagent.9.5.nupkg', `
        'encasesafe.7.07.nupkg', `
        'mcafeeagent.5.5.nupkg', `
        'safenet.10.2.nupkg', `
        'wincollect.7.2.5.nupkg'
    
    #Install Packages
    Set-Location C:\Temp\Agents
    
    ForEach ($PackageName in $Packages){
        
         WriteLog "Installing Package $PackageName"
         choco install $PackageName -y -dv -s . 
    }



