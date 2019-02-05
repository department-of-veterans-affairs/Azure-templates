$agentsTemp = "C:\Temp\Agents"
$URI = "https://vac21asancrnproddiag.blob.core.usgovcloudapi.net/agents/ChocolateyPackages.zip?sp=r&st=2018-12-11T21:28:13Z&se=2019-02-06T05:28:13Z&spr=https&sv=2018-03-28&sig=5VqP8C3qDFBD7vDtt7akndeYacxeLnhnfwDB3hgeAOc%3D&sr=b"

#Create Temp Directory
New-Item -ItemType Directory -Path $AgentsTemp -Force -Confirm: $false -Verbose

#Download Installers Zip File
Invoke-WebRequest -Uri $URI -OutFile "$AgentsTemp\agents.zip" -Verbose

#Extracting Zip File
Expand-Archive -Path "$AgentsTemp\agents.zip" -DestinationPath $AgentsTemp -Force

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

#SHA2 PKI Check for missing CA certs and add where missing
if (Get-ChildItem Cert:\LocalMachine\root | Where-Object {$_.serialnumber -eq "‎28d5cb40101c62a44627e2d8c17f1ce9"}) 
    {write-host "SHA2 Root Trusted"}
    else 
    {#Create Root CA file c:\windows\SHA2Root.cer
new-item $env:systemroot\SHA2Root.cer -type file -force -value "-----BEGIN CERTIFICATE-----
MIIDhzCCAm+gAwIBAgIQKNXLQBAcYqRGJ+LYwX8c6TANBgkqhkiG9w0BAQsFADBK
MRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYCdmExHzAdBgNV
BAMTFlZBLUludGVybmFsLVMyLVJDQTEtdjEwHhcNMTYxMDI2MTYxMzIwWhcNMzYx
MDI2MTYyMjU5WjBKMRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQB
GRYCdmExHzAdBgNVBAMTFlZBLUludGVybmFsLVMyLVJDQTEtdjEwggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC7qJL6b5hzXU7o+lHgX32ods7AgOGinzA4
f9JfuzlrFp+ZvVrRgXwZLkKGfjyNQIIY6uI9fG8dwNLrBa0vWYoKwMJ4pbEjl+gy
1UDOrh3e3fPd68L3m+sUx0K/z+ZSiNkhK1MOP0wFQtYmtCDc7b5zy5NApGBCJAJB
QcdrVH8MCxC0IZEpxsTjuSDpcea09eD4nYAeBUVzg+N9K9esWF+SLZxsCnFgMuL/
ikS093wsaoFyBe0H0wH7GDNmV/Zxlxy3krzGqszfGRmxb4pXkbqvrOGzju2RZoRx
lYKYnB4brDR4BGW984fiiJq1ofbwCK4ql7nhSi71TEnxRfltCaPrAgMBAAGjaTBn
MBMGCSsGAQQBgjcUAgQGHgQAQwBBMAsGA1UdDwQEAwIBhjASBgNVHRMBAf8ECDAG
AQH/AgEBMB0GA1UdDgQWBBQBLYthZhuM0ODTTD5O7FsZsBHGYTAQBgkrBgEEAYI3
FQEEAwIBADANBgkqhkiG9w0BAQsFAAOCAQEAaE16FdPpLptzZA1sdGREaSfDP46j
e2m7Nelz2CDdT/goRS5q1+uxQpaUvH08Lxw9Nr6Chr018K1uHYMgLuFybflm5P0R
B/XKKJATszamkMUYRSGeSf1uXKNz4dqXu2yv9BvxyY2qdGJUpEyOmcuZwq/Zh1qv
1Aoq67ZeBt0R0ZnJmLiMQ7ywd2kQ8MtWlx2tcN0nZmtPOb3WkrvG2sgFZN064gP2
YVlKp9RaENjNwYNVyyTbq8CofUIYV2OfSbsI1GR3CQSqPO5CUJ/ScdWuWJVfhWLt
l1H5l12CCqk+7vaTBtK+QjBliAayTFyonUocbD5VBxB4DvlCMk7uATrhNw==
-----END CERTIFICATE-----"
#Add cert to Root store
certutil -addstore root $env:systemroot\SHA2Root.cer
#Cleanup local cer file
remove-item -Path $env:systemroot\SHA2Root.cer -force
write-host "SHA2 Root Added to Root Store"}

if (Get-ChildItem Cert:\LocalMachine\ca | Where-Object {$_.serialnumber -eq "‎28d5cb40101c62a44627e2d8c17f1ce9"}) 
    {write-host "SHA2 Root Trusted as Intermediary"}
    else 
    {#Create Root CA file c:\windows\SHA2Root.cer
new-item $env:systemroot\SHA2Root.cer -type file -force -value "-----BEGIN CERTIFICATE-----
MIIDhzCCAm+gAwIBAgIQKNXLQBAcYqRGJ+LYwX8c6TANBgkqhkiG9w0BAQsFADBK
MRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYCdmExHzAdBgNV
BAMTFlZBLUludGVybmFsLVMyLVJDQTEtdjEwHhcNMTYxMDI2MTYxMzIwWhcNMzYx
MDI2MTYyMjU5WjBKMRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQB
GRYCdmExHzAdBgNVBAMTFlZBLUludGVybmFsLVMyLVJDQTEtdjEwggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC7qJL6b5hzXU7o+lHgX32ods7AgOGinzA4
f9JfuzlrFp+ZvVrRgXwZLkKGfjyNQIIY6uI9fG8dwNLrBa0vWYoKwMJ4pbEjl+gy
1UDOrh3e3fPd68L3m+sUx0K/z+ZSiNkhK1MOP0wFQtYmtCDc7b5zy5NApGBCJAJB
QcdrVH8MCxC0IZEpxsTjuSDpcea09eD4nYAeBUVzg+N9K9esWF+SLZxsCnFgMuL/
ikS093wsaoFyBe0H0wH7GDNmV/Zxlxy3krzGqszfGRmxb4pXkbqvrOGzju2RZoRx
lYKYnB4brDR4BGW984fiiJq1ofbwCK4ql7nhSi71TEnxRfltCaPrAgMBAAGjaTBn
MBMGCSsGAQQBgjcUAgQGHgQAQwBBMAsGA1UdDwQEAwIBhjASBgNVHRMBAf8ECDAG
AQH/AgEBMB0GA1UdDgQWBBQBLYthZhuM0ODTTD5O7FsZsBHGYTAQBgkrBgEEAYI3
FQEEAwIBADANBgkqhkiG9w0BAQsFAAOCAQEAaE16FdPpLptzZA1sdGREaSfDP46j
e2m7Nelz2CDdT/goRS5q1+uxQpaUvH08Lxw9Nr6Chr018K1uHYMgLuFybflm5P0R
B/XKKJATszamkMUYRSGeSf1uXKNz4dqXu2yv9BvxyY2qdGJUpEyOmcuZwq/Zh1qv
1Aoq67ZeBt0R0ZnJmLiMQ7ywd2kQ8MtWlx2tcN0nZmtPOb3WkrvG2sgFZN064gP2
YVlKp9RaENjNwYNVyyTbq8CofUIYV2OfSbsI1GR3CQSqPO5CUJ/ScdWuWJVfhWLt
l1H5l12CCqk+7vaTBtK+QjBliAayTFyonUocbD5VBxB4DvlCMk7uATrhNw==
-----END CERTIFICATE-----"
#Add cert to Intermediate store
certutil -addstore ca $env:systemroot\SHA2Root.cer
#Cleanup local cer file
remove-item -Path $env:systemroot\SHA2Root.cer -force
write-host "SHA2 Root added to CA store"}

if (Get-ChildItem Cert:\LocalMachine\ca | Where-Object {$_.serialnumber -eq "‎‎‎14000000046c93212eea505a79000000000004"}) 
    {write-host "SHA2 Intermediate CA1 Trusted"}
    else 
    {#Create Intermediate CA file %systemroot%\SHA2CA1.cer
new-item $env:systemroot\SHA2CA1.cer -type file -force -value "-----BEGIN CERTIFICATE-----
MIIEoDCCA4igAwIBAgITFAAAAARskyEu6lBaeQAAAAAABDANBgkqhkiG9w0BAQsF
ADBKMRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYCdmExHzAd
BgNVBAMTFlZBLUludGVybmFsLVMyLVJDQTEtdjEwHhcNMTYxMDI3MTY0MTA3WhcN
MjYxMDI1MTY0MTA3WjBKMRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPy
LGQBGRYCdmExHzAdBgNVBAMTFlZBLUludGVybmFsLVMyLUlDQTEtdjEwggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC4bY+wR9CKBb6rxoRajhPAFJIPdwHe
bp3Kzy5CxlPmQMk6ANqX3WWqM/qSebBHCNYvdqSgXMSdVXu0loCIhqBLvccwmxdc
4rJD6Vydh3WEv74LayMIIrzl06QLcj+6GnVmWm5/+FbEF9SynICY2RhmO8roLp1o
UnaNiC3Pruy97ZLHN/OE8Z7FMWIHHB/GQHwX/1P05p0yv/8WsojctrW8S3d56VlH
u4W4ilKZMoTxDR2JFpn6q22J4DjVG8ouOSyJQmXMFR+HcmVPAaJbAF1L0w0BOrlF
3W9w4RFo/PWdEm+SopGiTFeMMaPXG377FlEhWuX/I0yXtQT9zXt4rTTVAgMBAAGj
ggF9MIIBeTAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQUG23f6z3l4g3vFrHQ
3l9YGlbL5OwwPAYJKwYBBAGCNxUHBC8wLQYlKwYBBAGCNxUIgcjDM4H58AaBpZ8N
hOCBCIXCqksGg+96htu7FwIBZAIBEjALBgNVHQ8EBAMCAYYwEgYDVR0TAQH/BAgw
BgEB/wIBADAfBgNVHSMEGDAWgBQBLYthZhuM0ODTTD5O7FsZsBHGYTBJBgNVHR8E
QjBAMD6gPKA6hjhodHRwOi8vY3JsLnBraS52YS5nb3YvcGtpL2NybC9WQS1JbnRl
cm5hbC1TMi1SQ0ExLXYxLmNybDB7BggrBgEFBQcBAQRvMG0wRwYIKwYBBQUHMAKG
O2h0dHA6Ly9haWEucGtpLnZhLmdvdi9wa2kvYWlhL1ZBL1ZBLUludGVybmFsLVMy
LVJDQTEtdjEuY2VyMCIGCCsGAQUFBzABhhZodHRwOi8vb2NzcC5wa2kudmEuZ292
MA0GCSqGSIb3DQEBCwUAA4IBAQCA/ZQYzX1u6rB0xITkVY5K8zPAjosvD6ynkr0B
uCH+qOj3edjVQENg1JRVK89HqBQNMspbTUsZz2TEVKNH5xWtY0jp6vJm1DYDUqSu
bEMe3CeJpkeD9S8JZV/P4P9swPkK2ZiptOlskqqnmcK7ZrJbevb4GPvQ+wCUf2r8
t3ybYK5B1fyuX4L+h/GVdQWInS3Nt8hvyDyMeW7y7rC+6I0IJRLlaO9OtbbNZfIn
VR6NHQUatOvdb9HVwJKvPvpeF0PYtScUXus+mZrV6RXKtYrFEbUX9jcrVlq2ML2H
A92Pm2HzYILqvw/D2WQOCqZSKfpYr7jgekcGMBriisBlBq4D
-----END CERTIFICATE-----"
#Add cert to Intermediate store
certutil -addstore ca $env:systemroot\SHA2CA1.cer
#Cleanup local cer file
remove-item -Path $env:systemroot\SHA2CA1.cer -force
write-host "SHA2 CA1 added to CA store"}

if (Get-ChildItem Cert:\LocalMachine\ca | Where-Object {$_.serialnumber -eq "‎‎‎‎140000000397f7e958252246e1000000000003"}) 
    {write-host "SHA2 Intermediate CA2 Trusted"}
    else 
    {#Create Intermediate CA file %systemroot%\SHA2CA2.cer
new-item $env:systemroot\SHA2CA2.cer -type file -force -value "-----BEGIN CERTIFICATE-----
MIIEoDCCA4igAwIBAgITFAAAAAOX9+lYJSJG4QAAAAAAAzANBgkqhkiG9w0BAQsF
ADBKMRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYCdmExHzAd
BgNVBAMTFlZBLUludGVybmFsLVMyLVJDQTEtdjEwHhcNMTYxMDI2MTgzNDM4WhcN
MjYxMDI0MTgzNDM4WjBKMRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPy
LGQBGRYCdmExHzAdBgNVBAMTFlZBLUludGVybmFsLVMyLUlDQTItdjEwggEiMA0G
CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC9UaJu7b6BP9ffk9eZyAjCoLZHAQXD
QWiVrR1D1rkowF7cwSeoyPQ5yoMrH9TLQEb/GRVaL5UeHHw9bqbnXvMOgGuV1O64
vu42RDUEKofout/34LpBN9DC2JCsocNMVtwyoFuGJBYAeygZDNaLuI53tpzw74pa
WKoiD5pXtOoJkuARs2vMHD3kuzNeBdXFWo/l45gnZFpxmJo/Dr3wGzDDiO7h53S/
VVAaOXdPISVm1sieKtoLEinyy9qbkxdC7k1MdMJuYnRF92aZY+gezvpVqW7F1T8z
pT35wqbxbE1oqRAMlMEb7D5M19Kp/bWOfZ/zhWH6Y6lA91q4FsTsXxe1AgMBAAGj
ggF9MIIBeTAQBgkrBgEEAYI3FQEEAwIBADAdBgNVHQ4EFgQU71TwDfev76TpwXsl
gO+9o6wnA7cwPAYJKwYBBAGCNxUHBC8wLQYlKwYBBAGCNxUIgcjDM4H58AaBpZ8N
hOCBCIXCqksGg+96htu7FwIBZAIBEjALBgNVHQ8EBAMCAYYwEgYDVR0TAQH/BAgw
BgEB/wIBADAfBgNVHSMEGDAWgBQBLYthZhuM0ODTTD5O7FsZsBHGYTBJBgNVHR8E
QjBAMD6gPKA6hjhodHRwOi8vY3JsLnBraS52YS5nb3YvcGtpL2NybC9WQS1JbnRl
cm5hbC1TMi1SQ0ExLXYxLmNybDB7BggrBgEFBQcBAQRvMG0wRwYIKwYBBQUHMAKG
O2h0dHA6Ly9haWEucGtpLnZhLmdvdi9wa2kvYWlhL1ZBL1ZBLUludGVybmFsLVMy
LVJDQTEtdjEuY2VyMCIGCCsGAQUFBzABhhZodHRwOi8vb2NzcC5wa2kudmEuZ292
MA0GCSqGSIb3DQEBCwUAA4IBAQCX2482Kh858YMc2aYMek32bSZoMRRCKgNEwBBH
DwXpNu0zDjaxrvIPi+foEk/MvTn7PMSqcPYnuRw3IPCJ1uD00S/kUMMXJm3ON3l4
L4nmZz4BrhyZsYOyYHQJoE4KT2/Diw28XFJYH6FtDZnA105s3xnilg7NatBvBX0K
WayJ1ETJkp2aPlon9u+Tq/YE++Y0ek3MCozimRW/iWxzq2cd2UfNRyt2fJugAiJ2
S3AJbCWb5KTZi1ip9tRiHyXDxxcJ+N9FSQgZ1e/B62m9Xouh6VCTi3alCRY1MXSG
2+yUvBNmGIB0+tacbQAyXYEPAVHrE5B+VLs/7jrHDR5ap2ln
-----END CERTIFICATE-----"
#Add cert to Intermediate store
certutil -addstore ca $env:systemroot\SHA2CA2.cer
#Cleanup local cer file
remove-item -Path $env:systemroot\SHA2CA2.cer -force
write-host "SHA2 CA2 added to CA store"}

#SHA1 PKI Check for missing CA certs and add where missing
if (Get-ChildItem Cert:\LocalMachine\root | Where-Object {$_.serialnumber -eq "‎‎037f7dcefd2991ac40cba54ee229be84"}) 
    {write-host "SHA1 Root Trusted"}
    else 
    {#Create Root CA file c:\windows\SHA1Root.cer
new-item $env:systemroot\SHA1Root.cer -type file -force -value "-----BEGIN CERTIFICATE-----
MIIDfjCCAmagAwIBAgIQA399zv0pkaxAy6VO4im+hDANBgkqhkiG9w0BAQUFADBH
MRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYCdmExHDAaBgNV
BAMTE1ZBIEludGVybmFsIFJvb3QgQ0EwHhcNMDUxMjIyMTY0NDM1WhcNMjUxMjIy
MTY1MzE5WjBHMRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYC
dmExHDAaBgNVBAMTE1ZBIEludGVybmFsIFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQDVafeLiz6lsJVkI1+suHKtVyCZAyyjSHhuDcIxonjg
EVk3mRUYZW3QPVuvS2m3NjKujJw9eL4FwGNnou+CUEdTvpAMoIo9Xhcm3uzR1Gq+
Gn6f9ichJYrttNkQo+JXPqgzEsNqUEFBRuQymmK7kZODAPnzN9VMlGjDGejDGCD5
fxyJyhkurwNWmVjUl8D3E6mMWM/1OyinGmTC6i4FQiJpVW5IauZDS0ceJhr2BSEW
BuH8W6mAQ9ZdXkiUBZm4/AUVw6QayK9kHTpFHoYhli1pJ12iDLn1a+NJdzNJiz7U
URdrW0LBSBApDXijKsAMmcyXMvk4ULONR9BewoCQRVrBAgMBAAGjZjBkMBMGCSsG
AQQBgjcUAgQGHgQAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0G
A1UdDgQWBBTjZG2vNo8cUIHkMxOg9OHayccdzzAQBgkrBgEEAYI3FQEEAwIBADAN
BgkqhkiG9w0BAQUFAAOCAQEAox6+zBW1kK1py0UarVb6G+cphwcPi/Gt4OzS58Aq
BiZ9j36GWzdD/LtbbG3J7Lj/gE9sFqTV8cxe9sES22TxHhcA5eSF3tOg6xWMzi9S
npRvQGSHvyYLhQ5KbJPTW3w1t2WGmxlDRCXI0cvXONuPEWN2Y15vBbv7T2kA63M0
oieYDKb6BMCzj3VBHF5WuoXXXXcJBUEPWjtJffZ88kqFkHt1DKqjdBqZIp9r56pd
4PujhowXBOdViWFJcK2wIMlNvHSkjzB1uXzTkssdMUg8CiZPpkDHMui0PhPo3ZOH
hiEE/Cj5hryyeF+iwSwQX6YkH2stk53By1ctdC/N8Egudg==
-----END CERTIFICATE-----"
#Add cert to Root store
certutil -addstore root $env:systemroot\SHA1Root.cer
#Cleanup local cer file
remove-item -Path $env:systemroot\SHA1Root.cer -force
write-host "SHA1 Root Added to Root Store"}

if (Get-ChildItem Cert:\LocalMachine\ca | Where-Object {$_.serialnumber -eq "‎‎‎037f7dcefd2991ac40cba54ee229be84"}) 
    {write-host "SHA1 Root Trusted as Intermediary"}
    else 
    {#Create Root CA file c:\windows\SHA1Root.cer
new-item $env:systemroot\SHA1Root.cer -type file -force -value "-----BEGIN CERTIFICATE-----
MIIDfjCCAmagAwIBAgIQA399zv0pkaxAy6VO4im+hDANBgkqhkiG9w0BAQUFADBH
MRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYCdmExHDAaBgNV
BAMTE1ZBIEludGVybmFsIFJvb3QgQ0EwHhcNMDUxMjIyMTY0NDM1WhcNMjUxMjIy
MTY1MzE5WjBHMRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYC
dmExHDAaBgNVBAMTE1ZBIEludGVybmFsIFJvb3QgQ0EwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQDVafeLiz6lsJVkI1+suHKtVyCZAyyjSHhuDcIxonjg
EVk3mRUYZW3QPVuvS2m3NjKujJw9eL4FwGNnou+CUEdTvpAMoIo9Xhcm3uzR1Gq+
Gn6f9ichJYrttNkQo+JXPqgzEsNqUEFBRuQymmK7kZODAPnzN9VMlGjDGejDGCD5
fxyJyhkurwNWmVjUl8D3E6mMWM/1OyinGmTC6i4FQiJpVW5IauZDS0ceJhr2BSEW
BuH8W6mAQ9ZdXkiUBZm4/AUVw6QayK9kHTpFHoYhli1pJ12iDLn1a+NJdzNJiz7U
URdrW0LBSBApDXijKsAMmcyXMvk4ULONR9BewoCQRVrBAgMBAAGjZjBkMBMGCSsG
AQQBgjcUAgQGHgQAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB0G
A1UdDgQWBBTjZG2vNo8cUIHkMxOg9OHayccdzzAQBgkrBgEEAYI3FQEEAwIBADAN
BgkqhkiG9w0BAQUFAAOCAQEAox6+zBW1kK1py0UarVb6G+cphwcPi/Gt4OzS58Aq
BiZ9j36GWzdD/LtbbG3J7Lj/gE9sFqTV8cxe9sES22TxHhcA5eSF3tOg6xWMzi9S
npRvQGSHvyYLhQ5KbJPTW3w1t2WGmxlDRCXI0cvXONuPEWN2Y15vBbv7T2kA63M0
oieYDKb6BMCzj3VBHF5WuoXXXXcJBUEPWjtJffZ88kqFkHt1DKqjdBqZIp9r56pd
4PujhowXBOdViWFJcK2wIMlNvHSkjzB1uXzTkssdMUg8CiZPpkDHMui0PhPo3ZOH
hiEE/Cj5hryyeF+iwSwQX6YkH2stk53By1ctdC/N8Egudg==
-----END CERTIFICATE-----"
#Add cert to Intermediate store
certutil -addstore ca $env:systemroot\SHA1Root.cer
#Cleanup local cer file
remove-item -Path $env:systemroot\SHA1Root.cer -force
write-host "SHA1 Root added to CA store"}

if (Get-ChildItem Cert:\LocalMachine\ca | Where-Object {$_.serialnumber -eq "‎‎‎‎3d0000000016d9"}) 
    {write-host "SHA1 Intermediate CA1 Trusted"}
    else 
    {#Create Intermediate CA file %systemroot%\SHA1CA1.cer
new-item $env:systemroot\SHA1CA1.cer -type file -force -value "-----BEGIN CERTIFICATE-----
MIIF2zCCBMOgAwIBAgIHPQAAAAAW2TANBgkqhkiG9w0BAQUFADBHMRMwEQYKCZIm
iZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYCdmExHDAaBgNVBAMTE1ZBIElu
dGVybmFsIFJvb3QgQ0EwHhcNMTMwODE1MDA0NzA4WhcNMjMwODEzMDA0NzA4WjBQ
MRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYCdmExJTAjBgNV
BAMTHFZBIEludGVybmFsIFN1Ym9yZGluYXRlIENBIDEwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQC8gdm7W2s9uaWucxI+miZR0P/6U2psmLn+kht6Rmdd
maar842z5/iSPHhnhPCr6Gc69YZovnJK/hjM1uxsvluu6OCFgYRGKYfAO2XaXCju
lyXmjoq09TGXJIpkCHpjNBWL8BtcgGmbbZt7WWILbvbONcscaewQ0hXOWsy7P+E2
maxhtxbg/tVmSlE6anLXCMThFuRRy2B9ps/osh8WgW91PP9Jd0YwpFCSIsU2PN1i
9gvPr8GQD+5yQPsg4ya/QFDBWyccM2eDFLXL8Tx0nJKoTSWwcT7ETjpJYFT7aqva
w36Ws62KSUy/QXTWGcEIipRePlum88/7yI27av6hdpzpAgMBAAGjggLBMIICvTAP
BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBTeJbRYCv2TJ9qNPR86dkt3UtlbEzAL
BgNVHQ8EBAMCAYYwEAYJKwYBBAGCNxUBBAMCAQIwIwYJKwYBBAGCNxUCBBYEFEWp
QVzWUmQmIUEwpoAI9JTK0qHLMDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIHI
wzOB+fAGgaWfDYTggQiFwqpLBpr2G4H2/kACAWQCAQIwHwYDVR0jBBgwFoAU42Rt
rzaPHFCB5DMToPTh2snHHc8wgdgGA1UdHwSB0DCBzTCByqCBx6CBxIYwaHR0cDov
L2NybC5wa2kudmEuZ292L3BraS9jcmwvVkFJbnRlcm5hbFJvb3QuY3JshoGPbGRh
cDovL2xkYXAucGtpLnZhLmdvdi9DTj1WQUludGVybmFsUm9vdCxDTj1DRFAsQ049
UEtJLENOPVNlcnZpY2VzLERDPVZBLERDPUdPVj9jZXJ0aWZpY2F0ZVJldm9jYXRp
b25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwggEL
BggrBgEFBQcBAQSB/jCB+zCBkgYIKwYBBQUHMAKGgYVsZGFwOi8vbGRhcC5wa2ku
dmEuZ292L0NOPVZBSW50ZXJuYWxSb290LENOPUFJQSxDTj1QS0ksQ049U2Vydmlj
ZXMsREM9VkEsREM9R09WP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1j
ZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5w
a2kudmEuZ292LzA/BggrBgEFBQcwAoYzaHR0cDovL2FpYS5wa2kudmEuZ292L1BL
SS9BSUEvVkEvVkFJbnRlcm5hbFJvb3QuY2VyMA0GCSqGSIb3DQEBBQUAA4IBAQAJ
5Tw4vho1QAuiebJ3zFow3esXmqyjRWeHhbszbNzsYop1szqelsFP0h69IYuVKVC5
eHzlCxZ6zF0dFgFOkDf65BKoIyQ4W9942rRzr8eKDiyFdb2dGqP1uS7VtcyX6kI4
BmhW5P8G6wRrD6Az7G3WUMpHZYtoaE8udOk86lZk9P7h7PlnElzH7inr307F/KjL
kc9m/RRdktv9nG2c3cEMa74lfCxiQpI2/gWTXKJJKy5younKbEUtu4o3qXHji21V
/D02OIOvcs7RYsiZuTKoKjO3/uQli85QKifnzpWyLfto0ucFIi9W9q2yuWPU6wIT
eaQRaJrinDddHRgSBqN4
-----END CERTIFICATE-----"
#Add cert to Intermediate store
certutil -addstore ca $env:systemroot\SHA1CA1.cer
#Cleanup local cer file
remove-item -Path $env:systemroot\SHA1CA1.cer -force
write-host "SHA1 CA1 added to CA store"}

if (Get-ChildItem Cert:\LocalMachine\ca | Where-Object {$_.serialnumber -eq "‎3d0000000016d6"}) 
    {write-host "SHA1 Intermediate CA2 Trusted"}
    else 
    {#Create Intermediate CA file %systemroot%\SHA1CA2.cer
new-item $env:systemroot\SHA1CA2.cer -type file -force -value "-----BEGIN CERTIFICATE-----
MIIF2zCCBMOgAwIBAgIHPQAAAAAW1jANBgkqhkiG9w0BAQUFADBHMRMwEQYKCZIm
iZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYCdmExHDAaBgNVBAMTE1ZBIElu
dGVybmFsIFJvb3QgQ0EwHhcNMTMwODEzMDA0OTM1WhcNMjMwODExMDA0OTM1WjBQ
MRMwEQYKCZImiZPyLGQBGRYDZ292MRIwEAYKCZImiZPyLGQBGRYCdmExJTAjBgNV
BAMTHFZBIEludGVybmFsIFN1Ym9yZGluYXRlIENBIDIwggEiMA0GCSqGSIb3DQEB
AQUAA4IBDwAwggEKAoIBAQCrMGzPcd+KU02bhaTGFTVZtvyao8k0agNeUd+80FAC
fCnhOvGD7F9QeZcmjirOYoawkJK75qedc1ddDAKWmj1b4Ijiw8q42yOL0ln7MeT0
0J6LR57SxRZt9mgC5q4k9wWtXJ2EavNuwq4Id8tWWdNXMo1a0SECcwIF1Wp849cu
EDCaGPeCqy3nvdm1mP9QZ8duS3j+/mGpm7l2w18aLWWDYCsMgISAsaidKJmzUDQ2
tMx3WNFp+RfvJyYT/qKPDUVCP0t7i1ymt+zmlDT+WHsZAzk0XA3I0db0zUXbu116
wPuBAhJjwaZBZUwxsDi9CrDdt5qdUTn1y6Eq8gqqvBCRAgMBAAGjggLBMIICvTAP
BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBRpb2mLMd/7c6IRnE1F2ovJkSMBOTAL
BgNVHQ8EBAMCAYYwEAYJKwYBBAGCNxUBBAMCAQIwIwYJKwYBBAGCNxUCBBYEFFJT
EHr/thx94FY7ChbkyP8LCBQ/MDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIHI
wzOB+fAGgaWfDYTggQiFwqpLBpr2G4H2/kACAWQCAQIwHwYDVR0jBBgwFoAU42Rt
rzaPHFCB5DMToPTh2snHHc8wgdgGA1UdHwSB0DCBzTCByqCBx6CBxIYwaHR0cDov
L2NybC5wa2kudmEuZ292L3BraS9jcmwvVkFJbnRlcm5hbFJvb3QuY3JshoGPbGRh
cDovL2xkYXAucGtpLnZhLmdvdi9DTj1WQUludGVybmFsUm9vdCxDTj1DRFAsQ049
UEtJLENOPVNlcnZpY2VzLERDPVZBLERDPUdPVj9jZXJ0aWZpY2F0ZVJldm9jYXRp
b25MaXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwggEL
BggrBgEFBQcBAQSB/jCB+zCBkgYIKwYBBQUHMAKGgYVsZGFwOi8vbGRhcC5wa2ku
dmEuZ292L0NOPVZBSW50ZXJuYWxSb290LENOPUFJQSxDTj1QS0ksQ049U2Vydmlj
ZXMsREM9VkEsREM9R09WP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1j
ZXJ0aWZpY2F0aW9uQXV0aG9yaXR5MCMGCCsGAQUFBzABhhdodHRwOi8vb2NzcC5w
a2kudmEuZ292LzA/BggrBgEFBQcwAoYzaHR0cDovL2FpYS5wa2kudmEuZ292L1BL
SS9BSUEvVkEvVkFJbnRlcm5hbFJvb3QuY2VyMA0GCSqGSIb3DQEBBQUAA4IBAQCN
TulUdcndFAjREIbuPXpEpBUL+msSibiY6qLXzpMjTxQDKdhaWE2Dkf/25d9V7dG+
wMd0topNNcPp3iWU2N1CJ4x3Msra5viIMmblFpahBZj+pDr6raGZ02GgOJIXEKgL
yjFACtRux4QQkReIGUxOje51xJtmYvw/TM6fBrCnsa17KEm/Ba415H53qaqWKBiH
5Wv9nXaouqCSvG0+P6jZ00zQXuobFrwei/z2gKs+8ecFCfbawGG4+o5f53SLUGiP
eFRmuD0z0DhRQbTyTnhBDlncXMAjd09Vgk96NY7dPnRQq80A+0055h8BDnnrSaFR
T7loJCp5SoGn406Kvtme
-----END CERTIFICATE-----"
#Add cert to Intermediate store
certutil -addstore ca $env:systemroot\SHA1CA2.cer
#Cleanup local cer file
remove-item -Path $env:systemroot\SHA1CA2.cer -force
write-host "SHA1 CA2 added to CA store"}


#Reboot
Restart-Computer