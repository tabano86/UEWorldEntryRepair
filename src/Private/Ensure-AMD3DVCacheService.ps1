param($Name)
try {
  $s = Get-Service -Name $Name -ErrorAction Stop
  if ($s.Status -ne "Running") {
    sc.exe config $Name start= auto | Out-Null
    Start-Service $Name -ErrorAction SilentlyContinue
    & (Join-Path $PSScriptRoot "Write-ActionLog.ps1") "$Name started" "OK" $script:LogFile
  } else {
    & (Join-Path $PSScriptRoot "Write-ActionLog.ps1") "$Name running" "OK" $script:LogFile
  }
} catch {
  & (Join-Path $PSScriptRoot "Write-ActionLog.ps1") "$Name not present" "WARN" $script:LogFile
}