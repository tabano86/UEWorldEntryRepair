param([string[]]$Paths,[switch]$DryRun)
foreach($p in $Paths){
  if(Test-Path $p){
    try{
      if(-not $DryRun){Remove-Item -Recurse -Force $p -ErrorAction Stop}
      & (Join-Path $PSScriptRoot 'Write-ActionLog.ps1') "Delete $p" "OK"
    }catch{
      & (Join-Path $PSScriptRoot 'Write-ActionLog.ps1') "Delete $p — $($_.Exception.Message)" "WARN"
    }
  } else {
    & (Join-Path $PSScriptRoot 'Write-ActionLog.ps1') "Delete $p — not found" "WARN"
  }
}
