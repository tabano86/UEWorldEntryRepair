function Stop-GameOverlays {
    param([string[]]$Names,[string]$LogFile)
    foreach ($n in $Names) {
        Get-Process -Name $n -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Stop-Process -Id $_.Id -Force -ErrorAction Stop
                Write-ActionLog -Message ("Killed {0}" -f $_.ProcessName) -Level OK -LogFile $LogFile
            } catch {
                Write-ActionLog -Message ("{0} - {1}" -f $_.ProcessName, $_.Exception.Message) -Level WARN -LogFile $LogFile
            }
        }
    }
}
