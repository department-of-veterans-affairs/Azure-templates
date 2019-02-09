configuration WebandSQLConfig
{	
    Import-DscResource -ModuleName PSDesiredStateConfiguration
    
    Node WebServer
    {
        WindowsFeatureSet WebRoles
        {
            Ensure = 'Present'
            Name   = @("Web-Server", "Web-WebServer", "Web-Common-Http", "Web-Default-Doc", "Web-Dir-Browsing", "Web-Http-Errors", "Web-Static-Content", "Web-Health", "Web-Http-Logging", "Web-Log-Libraries", "Web-Request-Monitor", "Web-Performance", "Web-Stat-Compression", "Web-Security", "Web-Filtering", "Web-App-Dev", "Web-Net-Ext", "Web-Net-Ext45", "Web-Asp-Net", "Web-Asp-Net45", "Web-ISAPI-Ext", "Web-ISAPI-Filter", "Web-Mgmt-Tools", "Web-Mgmt-Console", "Web-Mgmt-Service")
        }
         #Install ASP.NET 4.5
        WindowsFeatureSet NETFramework
        {
            Ensure = 'Present'
            Name = @('NET-Framework-Features','NET-Framework-Core', 'NET-Framework-45-Features', 'NET-Framework-45-Core', 'NET-Framework-45-ASPNET', 'NET-WCF-Services45', 'NET-WCF-TCP-PortSharing45')
        }

        WindowsFeatureSet WAS
        {
            Ensure = 'Present'
            Name = @('WAS','WAS-Process-Model','WAS-NET-Environment')            
        }

        WindowsFeatureSet FileServices
        {
            Ensure = 'Present'
            Name = @('File-Services', 'FS-FileServer', 'FS-SMB1')
        }
        
        WindowsFeature PSv2
        {
            Ensure = 'Present'
            Name = 'PowerShell-V2'
        }
        
        WindowsFeature RDC
        {
            Ensure = 'Present'
            Name = 'RDC'
        }
        
        WindowsFeature Telnet
        {
            Ensure = 'Present'
            Name = 'Telnet-Client'
        }

        WindowsFeature EnhancedStorage
        {
            Ensure = 'Present'
            Name = 'EnhancedStorage'
        }       
    }

    Node SQLServer
    {    
        
        WindowsFeatureSet NETFramework
        {
            Ensure = 'Present'
            Name = @('NET-Framework-Features','NET-Framework-Core', 'NET-Framework-45-Features', 'NET-Framework-45-Core', 'NET-WCF-Services45', 'NET-WCF-TCP-PortSharing45')
        }
        
        WindowsFeatureSet WAS
        {
            Ensure = 'Present'
            Name = @('WAS','WAS-Process-Model','WAS-NET-Environment')            
        }

        WindowsFeatureSet FileServices
        {
            Ensure = 'Present'
            Name = @('File-Services', 'FS-FileServer', 'FS-SMB1')
        }
        
        WindowsFeature PSv2
        {
            Ensure = 'Present'
            Name = 'PowerShell-V2'
        }
        
        WindowsFeature RDC
        {
            Ensure = 'Present'
            Name = 'RDC'
        }
        
        WindowsFeature Telnet
        {
            Ensure = 'Present'
            Name = 'Telnet-Client'
        }

        WindowsFeature EnhancedStorage
        {
            Ensure = 'Present'
            Name = 'EnhancedStorage'
        }     
        
    }    
}