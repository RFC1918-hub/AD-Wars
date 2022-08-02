[CmdletBinding()] Param (
    [String]
    $samAccountName,

    [String]
    $targetSamAccountName,

    [String]
    $distinguishedName,

    [ValidateSet('AccessSystemSecurity', 'CreateChild', 'Delete', 'DeleteChild', 'DeleteTree', 'ExtendedRight', 'GenericAll', 'GenericExecute', 'GenericRead', 'GenericWrite', 'ListChildren', 'ListObject', 'ReadControl', 'ReadProperty', 'Self', 'Synchronize', 'WriteDacl', 'WriteOwner', 'WriteProperty', 'ResetPassword', 'WriteMembers', 'DCSync')]
    [String]
    $right,

    [String]
    $rightGUID, 

    [String]
    $inheritance
)

if (!(Get-Module -ListAvailable -Name ActiveDirectory)) {
    $Ansible.Failed = $true
    Write-Warning "This function needs Active Directory module!"
    exit
}

if ($targetSamAccountName) {
    $objDN = (Get-ADUser -Identity $targetSamAccountName).distinguishedname
} elseif ($distinguishedName) {
    $objDN = $distinguishedName
} else {
    $Ansible.Failed = $true
    Write-Warning "Could not find target object!"
    exit
}

$AD = "AD"
$Path = $AD + ':\' + $objDN
$ACL = Get-Acl -Path $Path
$Identity = New-Object System.Security.Principal.NTAccount($samAccountName)

if ($rightGUID) {
    $GUIDs = @($rightGUID)
} else {
    $GUIDs = Switch ($right) {
        'ResetPassword' { '00299570-246d-11d0-a768-00aa006e0529' }
        'WriteMembers' { 'bf9679c0-0de6-11d0-a285-00aa003049e2' }
        'DCSync' { '1131f6aa-9c07-11d1-f79f-00c04fc2dcd2', '1131f6ad-9c07-11d1-f79f-00c04fc2dcd2', '89e95b76-444d-4c62-991a-0facbeda640c'}
    }
}

$InheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance] $inheritance
$ControlType = [System.Security.AccessControl.AccessControlType] 'Allow'

if ($GUIDs) {
    ForEach ($GUID in $GUIDs) {
        $NewGUID = New-Object Guid $GUID
        $ADRights = [System.DirectoryServices.ActiveDirectoryRights] 'ExtendedRight'
        $ACEGetChangesAll = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $Identity, $ADRights, $ControlType, $NewGUID, $InheritanceType
        $ACL.AddAccessRule($ACEGetChangesAll)
    }
} else {
    $ADRights = [System.DirectoryServices.ActiveDirectoryRights] $right
    $ACEGetChangesAll = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $Identity, $ADRights, $ControlType, $InheritanceType
}

try {
    Set-Acl $Path -AclObject $ACL
    $Ansible.Changed = $true
} catch {
    $Ansible.Failed = $true
}



