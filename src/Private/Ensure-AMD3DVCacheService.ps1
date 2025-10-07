param($Name)
try{
  $svc=Get-Service -Name $Name -ErrorAction Stop
  if($svc.Status -ne 'Running'){
    sc.exe config $Name start= auto | Out-Null
    Start-Service $Name -ErrorAction SilentlyContinue
    & (Join-Path $PSScriptRoot 'Write-ActionLog.ps1') "$Name started" "OK"
  } else {
    & (Join-Path $PSScriptRoot 'Write-ActionLog.ps1') "$Name running" "OK"
  }
}catch{
  & (Join-Path $PSScriptRoot 'Write-ActionLog.ps1') "$Name not present" "WARN"
}
