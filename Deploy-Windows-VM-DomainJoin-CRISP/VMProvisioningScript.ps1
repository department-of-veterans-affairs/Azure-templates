param (
    
    [string]$agentURI,
    [string]$groupToAdd

)

function WriteLog {
    Param( 
         $message
    )

    $timestampedMessage = $("[" + [System.DateTime]::Now + "] " + $message) | % {
        Out-File -InputObject $_ -FilePath '$env:WinDir\Temp\ProvisioningScript.log' -Append
    }
}

function unzip {
    param( [string]$ziparchive, [string]$extractpath )
    [System.IO.Compression.ZipFile]::ExtractToDirectory( $ziparchive, $extractpath )
}

$certURI="http://aia.pki.va.gov/pki/aia/va/"

$agentsTemp = "C:\Temp\Agents"
$certsTemp = "C:\Temp\Certs"

WriteLog "Script Begin"

WriteLog "Agent URL: $agentURI"

Add-Type -AssemblyName System.IO.Compression.FileSystem

#Create Temp Directory
New-Item -ItemType Directory -Path $agentsTemp -Force -Confirm: $false -Verbose
New-Item -ItemType Directory -Path $certsTemp -Force -Confirm: $false -Verbose

#Download Installers Zip File
Invoke-WebRequest -Uri $agentURI -OutFile "$agentsTemp\agents.zip" -Verbose

#Download Certificates
Invoke-WebRequest -Uri $certURI/VAInternalRoot.cer -OutFile "$certsTemp\VAInternalRoot.cer"
Invoke-WebRequest -Uri $certURI/VA-Internal-S2-RCA1-v1.cer -OutFile "$certsTemp\VA-Internal-S2-RCA1-v1.cer"
Invoke-WebRequest -Uri $certURI/VA-Internal-S2-ICA2-v1.cer -OutFile "$certsTemp\VA-Internal-S2-ICA2-v1.cer"
Invoke-WebRequest -Uri $certURI/VA-Internal-S2-ICA1-v1.cer -OutFile "$certsTemp\VA-Internal-S2-ICA1-v1.cer"
Invoke-WebRequest -Uri $certURI/InternalSubCA2.cer -OutFile "$certsTemp\InternalSubCA2.cer"
Invoke-WebRequest -Uri $certURI/InternalSubCA1.cer -OutFile "$certsTemp\InternalSubCA1.cer"

#Extracting Zip File
unzip "$agentsTemp\agents.zip" $agentsTemp

#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression $agentsTemp\chocolatey\chocolateyInstall.ps1

$nupkgs=Get-ChildItem $agentsTemp | where {$_.name -like '*.nupkg'}

#Install Packages
Set-Location $sagentsTemp
ForEach ($pkg in $nupkgs)
{ WriteLog "Installing Package $pkg.name"
choco install $pkg.name -y -dv -s . }

$certsToImport=Get-ChildItem $certsTemp

ForEach ($cert in $certsToImport){

write-host $cert.Name
    
    $certDetails = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        
    $certDetails.Import($certsTemp+'\'+$cert.Name)
        
    #Check to see if the certificate is already imported into the Root store
    if (-not (Get-Childitem cert:\LocalMachine\Root | Where-Object {$_.Thumbprint -eq $certDetails.Thumbprint})) {
            
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "CA", "LocalMachine"
           
        #Open the Root store in Read/Write mode
        $store.Open("ReadWrite")
            
        #Import the cert
        $store.Add($certDirectory+'\'+$cert)
            
        #Close the store
        $store.Close()
            
        WriteLog "$cert has been imported into the Root store"
       }
       
        else {
            WriteLog $cert "was already present in the Intermediate Certificate Store"
       }
}


if ((Get-WmiObject -Class Win32_OperatingSystem).Version -ge "10*" -and (Get-WmiObject -Class Win32_OperatingSystem).Caption -like "*2016*") {

    WriteLog "Server 2016 Detected. Adding local group members"
                    
    Add-LocalGroupMember -Group 'Administrators' -Member $groupToAdd
    Add-LocalGroupMember -Group 'Remote Desktop Users' -Member $groupToAdd

    
    elseif ((Get-WmiObject -Class Win32_OperatingSystem).Version -like "6.3*" -and (Get-WmiObject -Class Win32_OperatingSystem).Caption -like "*2012 R2*") {
        Write-Output "Windows Server 2012 R2 detected."
        Write-Output "Not adding any local group/accounts..."
    }
}
