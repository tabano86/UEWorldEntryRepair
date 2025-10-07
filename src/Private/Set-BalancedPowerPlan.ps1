try {
  Start-Process powercfg -ArgumentList "-setactive SCHEME_BALANCED" -WindowStyle Hidden -Wait
  & (Join-Path $PSScriptRoot "Write-ActionLog.ps1") "Balanced plan set" "OK" $script:LogFile
} catch {
  & (Join-Path $PSScriptRoot "Write-ActionLog.ps1") ("Balanced plan error - {0}" -f $_.Exception.Message) "WARN" $script:LogFile
}