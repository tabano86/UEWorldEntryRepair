function Ensure-AMD3DVCacheService {
    param([string]$Name,[string]$LogFile)
    try {
        $s = Get-Service -Name $Name -ErrorAction Stop
        if ($s.Status -ne 'Running') {
            sc.exe config $Name start= auto | Out-Null
            Start-Service $Name -ErrorAction SilentlyContinue
            Write-ActionLog -Message "$Name started" -Level OK -LogFile $LogFile
        } else {
            Write-ActionLog -Message "$Name running" -Level OK -LogFile $LogFile
        }
    } catch {
        Write-ActionLog -Message "$Name not present" -Level WARN -LogFile $LogFile
    }
}
