[CmdletBinding()] Param (
    [String]
    $ansible_username, 

    [SecureString]
    $ansible_password
)

$iso_title = "Microsoft ATA 1.9"
$iso_path = "C:\ansible\$iso_title"
$downloadUrl = "http://download.microsoft.com/download/4/9/1/491394D1-3F28-4261-ABC6-C836A301290E/ATA1.9.iso"
$fileHash = "DC1070A9E8F84E75198A920A2E00DDC3CA8D12745AF64F6B161892D9F3975857"

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

# Install ATA Center
if (-not (Test-Path "C:\Program Files\Microsoft Advanced Threat Analytics\Center")) {
    if (-not (Test-Path $iso_path)) {
        do {
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $downloadUrl -OutFile $iso_path
            $actualHash = (Get-FileHash -Algorithm SHA256 -Path $iso_path).Hash
        } until ($actualHash -eq $fileHash)
    } else {
        $actualHash = (Get-FileHash -Algorithm SHA256 -Path $iso_path).Hash
        if (-not ($actualHash -eq $fileHash)) {
            do {
                $ProgressPreference = 'SilentlyContinue'
                Invoke-WebRequest -Uri $downloadUrl -OutFile $iso_path
                $actualHash = (Get-FileHash -Algorithm SHA256 -Path $iso_path).Hash
            } until ($actualHash -eq $fileHash)
        }
    }

    $mount = Mount-DiskImage -ImagePath $iso_path -StorageType ISO -Access ReadOnly -PassThru
    $volume = $mount | Get-Volume
    Start-Process -Wait -FilePath ($volume.DriveLetter + ':\Microsoft ATA Center Setup.exe') -ArgumentList "/q --LicenseAccepted NetFrameworkCommandLineArguments=`"/q`" --EnableMicrosoftUpdate" -PassThru
    $mount | Dismount-DiskImage -Confirm:$false

    $Ansible.Changed = $true
} else {
    $Ansible.Changed = $false
}

# Set the DC as the domain synchronizer
$config = Invoke-RestMethod -Uri "https://localhost/api/management/systemProfiles/gateways" -UseDefaultCredentials -UseBasicParsing
$config[0].Configuration.DirectoryServicesResolverConfiguration.UpdateDirectoryEntityChangesConfiguration.IsEnabled = $true

Invoke-RestMethod -Uri "https://localhost/api/management/systemProfiles/gateways/$($config[0].Id)" -UseDefaultCredentials -UseBasicParsing -Method Post -ContentType "application/json" -Body ($config[0] | convertto-json -depth 99)