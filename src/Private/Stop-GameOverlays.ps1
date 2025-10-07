param([string[]]$Names)
foreach ($n in $Names) {
  Get-Process -Name $n -ErrorAction SilentlyContinue | ForEach-Object {
    try {
      Stop-Process -Id $_.Id -Force -ErrorAction Stop
      & (Join-Path $PSScriptRoot "Write-ActionLog.ps1") ("Killed {0}" -f $_.ProcessName) "OK" $script:LogFile
    } catch {
      & (Join-Path $PSScriptRoot "Write-ActionLog.ps1") ("{0} - {1}" -f $_.ProcessName, $_.Exception.Message) "WARN" $script:LogFile
    }
  }
}