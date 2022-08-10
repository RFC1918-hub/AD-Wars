[CmdletBinding()]
    Param (
        [Switch]
        $shutdown,
        [Switch]
        $boot
    )

Get-AzContext | Format-List

if ($shutdown) {
    Get-AzVM -Status | %{Stop-AzVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name -Force}
} elseif ($boot) {
    Get-AzVM -Status | %{Start-AzVM -ResourceGroupName $_.ResourceGroupName -Name $_.Name -Force}
} else {
    Get-AzVM -Status
}
