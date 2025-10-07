function Set-BalancedPowerPlan {
    param([string]$LogFile)
    try {
        Start-Process powercfg -ArgumentList "-setactive SCHEME_BALANCED" -WindowStyle Hidden -Wait
        Write-ActionLog -Message "Balanced plan set" -Level OK -LogFile $LogFile
    } catch {
        Write-ActionLog -Message ("Balanced plan error - {0}" -f $_.Exception.Message) -Level WARN -LogFile $LogFile
    }
}
