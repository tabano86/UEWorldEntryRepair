try{
  Start-Process powercfg -ArgumentList "-setactive SCHEME_BALANCED" -WindowStyle Hidden -Wait
  & (Join-Path $PSScriptRoot 'Write-ActionLog.ps1') "Balanced plan set" "OK"
}catch{
  & (Join-Path $PSScriptRoot 'Write-ActionLog.ps1') "Balanced plan error — $($_.Exception.Message)" "WARN"
}
