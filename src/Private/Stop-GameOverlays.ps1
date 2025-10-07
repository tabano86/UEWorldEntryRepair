param([string[]]$Names)
foreach($n in $Names){
  Get-Process -Name $n -ErrorAction SilentlyContinue | ForEach-Object {
    try{
      Stop-Process -Id $_.Id -Force -ErrorAction Stop
      & (Join-Path $PSScriptRoot 'Write-ActionLog.ps1') "Killed $($_.ProcessName)" "OK"
    }catch{
      & (Join-Path $PSScriptRoot 'Write-ActionLog.ps1') "$($_.ProcessName) — $($_.Exception.Message)" "WARN"
    }
  }
}
