[CmdletBinding()] Param (

    [String]
    $ansible_username, 

    [String]
    $ansible_pass
)

# Enable web requests to endpoints with invalid SSL certs (like self-signed certs)
If (-not("SSLValidator" -as [type])) {
    add-type -TypeDefinition @"
    using System;
    using System.Net;
    using System.Net.Security;
    using System.Security.Cryptography.X509Certificates;

    public static class SSLValidator {
        public static bool ReturnTrue(object sender,
            X509Certificate certificate,
            X509Chain chain,
            SslPolicyErrors sslPolicyErrors) { return true; }

        public static RemoteCertificateValidationCallback GetDelegate() {
            return new RemoteCertificateValidationCallback(SSLValidator.ReturnTrue);
        }
    }
"@
}
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = [SSLValidator]::GetDelegate()

Add-Content 'c:\\windows\\system32\\drivers\\etc\\hosts' '        192.168.56.22    jedi-archives'

if (-not (Test-Path "C:\Program Files\Microsoft Advanced Threat Analytics")) {
    if (-not (Test-Path "$env:temp\gatewaysetup.zip")) {
        $ProgressPreference = 'SilentlyContinue'
        $passwd = ConvertTo-SecureString "AnsibleS3curePassw0rd" -AsPlainText -Force
        $creds = New-Object System.Management.Automation.PSCredential ("ansible", $passwd)
        Invoke-WebRequest -uri https://jedi-archives/api/management/softwareUpdates/gateways/deploymentPackage -UseBasicParsing -OutFile "$env:temp\gatewaysetup.zip" -Credential $creds
        Expand-Archive -Path "$env:temp\gatewaysetup.zip" -DestinationPath "$env:temp\gatewaysetup" -Force    
    }

    try {
        Set-Location "$env:temp\gatewaysetup"
        Start-Process -Wait -FilePath ".\Microsoft ATA Gateway Setup.exe" -ArgumentList "/q NetFrameworkCommandLineArguments=`"/q`" ConsoleAccountName=$ansible_username ConsoleAccountPassword=$ansible_pass"
    }
    catch {
        Exit 1
    }
} else {
    if ((Get-Service "ATAGateway").Status -ne "Running") {
        $Ansible.Changed = $true
    } else {
        $Ansible.Changed = $false
        Exit 0
    }
}