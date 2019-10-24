<#
    .SYNOPSIS
    This script installs the CRISP components to a VM in Azure

    .PARAMETER agentURI
    The HTTPS SAS URL to the CRISP Components

    .PARAMETER domainGroupToAdd
    The name of the domain group to add to the local admin group on the VM.
    This is used to provide access to the VM after it is domain joined.
#>

Param (
    [parameter(mandatory)]
    [string]
    $agentURI,

    [string]
    $domainGroupToAdd
)

function Expand-AgentZip
{
    param( [string]$ziparchive, [string]$extractpath )
    [System.IO.Compression.ZipFile]::ExtractToDirectory( $ziparchive, $extractpath )
}

function Write-LogFile
{
    Param(
        [parameter(mandatory)]
        [string]
        $message
    )

    $timestampedMessage = $("[" + [System.DateTime]::Now + "] " + $message) | % {
        Out-File -InputObject $_ -FilePath "$env:WinDir\Temp\ProvisioningScript.log" -Append
    }
}

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@

$AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

#Cert URI for VA public cert chain
$certURI = "http://aia.pki.va.gov/pki/aia/va/"

#Set agent and certs directory
$agentsTemp = "C:\Temp\Agents"
$RootcertsTemp = "C:\Temp\RootCerts"
$CAcertsTemp = "C:\Temp\CACerts"


Write-LogFile "Script Begin"
Write-LogFile "Agent URL: $agentURI"

#Add assembly for unzipping CRISP components
Add-Type -AssemblyName System.IO.Compression.FileSystem

#Create Temp Directories
New-Item -ItemType Directory -Path $agentsTemp -Force -Confirm: $false -Verbose
New-Item -ItemType Directory -Path $rootcertsTemp -Force -Confirm: $false -Verbose
New-Item -ItemType Directory -Path $CAcertsTemp -Force -Confirm: $false -Verbose

#Download Installers Zip File
Invoke-WebRequest -Uri $agentURI -OutFile "$agentsTemp\agents.zip" -Verbose

#Download Certificates required to join a machine to the domain
Invoke-WebRequest -Uri $certURI/VAInternalRoot.cer -OutFile "$rootcertsTemp\VAInternalRoot.cer"
Invoke-WebRequest -Uri $certURI/VA-Internal-S2-RCA1-v1.cer -OutFile "$CAcertsTemp\VA-Internal-S2-RCA1-v1.cer"
Invoke-WebRequest -Uri $certURI/VA-Internal-S2-ICA2-v1.cer -OutFile "$CAcertsTemp\VA-Internal-S2-ICA2-v1.cer"
Invoke-WebRequest -Uri $certURI/VA-Internal-S2-ICA1-v1.cer -OutFile "$CAcertsTemp\VA-Internal-S2-ICA1-v1.cer"
Invoke-WebRequest -Uri $certURI/InternalSubCA2.cer -OutFile "$CAcertsTemp\InternalSubCA2.cer"
Invoke-WebRequest -Uri $certURI/InternalSubCA1.cer -OutFile "$CAcertsTemp\InternalSubCA1.cer"

#Build array of certificates to import
$RootcertsToImport = Get-ChildItem $rootcertsTemp
$CAcertsToImport = Get-ChildItem $CAcertsTemp

#Import certs to Root store
ForEach ($cert in $RootcertsToImport)
{
    $certDetails = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $certDetails.Import($rootcertsTemp + '\' + $cert.Name)
    #Check to see if the certificate is already imported into the Root store
    if (-not (Get-Childitem cert:\LocalMachine\Root | Where-Object { $_.Thumbprint -eq $certDetails.Thumbprint }))
    {
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
        #Open the Root store in Read/Write mode
        $store.Open("ReadWrite")
        #Import the cert
        $store.Add($rootcertsTemp + '\' + $cert)
        #Close the store
        $store.Close()
        Write-LogFile "$cert has been imported into the Root store"
    }
    else
    {
        Write-LogFile "$cert was already present in the Root Certificate Store"
    }
}
#Import certs to CA store
ForEach ($cert in $CAcertsToImport)
{
    $certDetails = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
    $certDetails.Import($CAcertsTemp + '\' + $cert.Name)
    #Check to see if the certificate is already imported into the Root store
    if (-not (Get-Childitem cert:\LocalMachine\CA | Where-Object { $_.Thumbprint -eq $certDetails.Thumbprint }))
    {
        $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "CA", "LocalMachine"
        #Open the Root store in Read/Write mode
        $store.Open("ReadWrite")
        #Import the cert
        $store.Add($CAcertsTemp + '\' + $cert)
        #Close the store
        $store.Close()
        Write-LogFile "$cert has been imported into the Root store"
    }
    else
    {
        Write-LogFile "$cert was already present in the CA Certificate Store"
    }
}

#Extracting Zip File
Expand-AgentZip "$agentsTemp\agents.zip" $agentsTemp

#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression $agentsTemp\chocolatey\chocolateyInstall.ps1

#Build array of CRISP components to install
$nupkgs = Get-ChildItem $agentsTemp | Where-Object { $_.name -like '*.nupkg' }

#Install CRISP components
Set-Location $agentsTemp

#Loop through array and install CRISP
ForEach ($pkg in $nupkgs)
{
    Write-LogFile "Installing Package $pkg.name"
    choco install $pkg.name -y -dv -s .
}

if ((Get-WmiObject -Class Win32_OperatingSystem).Version -ge "10*" -and (Get-WmiObject -Class Win32_OperatingSystem).Caption -like "*2016*")
{
    try
    {
        Write-LogFile "Server 2016 Detected. Adding domain group to local admins"
        Add-LocalGroupMember -Group 'Administrators' -Member $groupToAdd -ErrorAction Stop
        Write-LogFile 'Adding group member succeeded'             
        Restart-Computer
    }
    catch
    {
        Write-LogFile "Adding domain group failed with error: $($error[0].ToString())"
    }
}