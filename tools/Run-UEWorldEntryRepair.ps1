param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)
$installed=(Get-Module -ListAvailable UEWorldEntryRepair)
if(-not $installed){Write-Host 'UEWorldEntryRepair not installed. Running installer.' -ForegroundColor Yellow; & (Join-Path $PSScriptRoot 'Install-UEWorldEntryRepair.ps1') -Force}
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if(-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
  Start-Process PowerShell -Verb RunAs -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-File',"`"$PSCommandPath`"",'-Args',($Args -join ' ')
  exit
}
Import-Module UEWorldEntryRepair -Force
Repair-UEWorldEntry @Args
