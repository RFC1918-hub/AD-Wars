[CmdletBinding()]
    Param (
        [Switch]
        $shutdown,
        [Switch]
        $boot
    )

Get-AzContext | Format-List

if ($shutdown) {
    Get-AzVM -Status | ForEach-Object {Stop-AzVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name -Force}
} elseif ($boot) {
    Get-AzVM -Status | ForEach-Object {Start-AzVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name}
} else {
    Get-AzVM -Status
}
