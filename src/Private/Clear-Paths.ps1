param([string[]]$Paths,[switch]$DryRun)
foreach ($p in $Paths) {
  if (Test-Path $p) {
    try {
      if (-not $DryRun) { Remove-Item -Recurse -Force $p -ErrorAction Stop }
      & (Join-Path $PSScriptRoot "Write-ActionLog.ps1") "Delete $p" "OK" $script:LogFile
    } catch {
      & (Join-Path $PSScriptRoot "Write-ActionLog.ps1") ("Delete {0} - {1}" -f $p, $_.Exception.Message) "WARN" $script:LogFile
    }
  } else {
    & (Join-Path $PSScriptRoot "Write-ActionLog.ps1") "Delete $p - not found" "WARN" $script:LogFile
  }
}