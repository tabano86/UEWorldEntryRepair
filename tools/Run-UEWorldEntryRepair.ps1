[CmdletBinding()]
param(
    [ValidateSet('Full','Lite','Revert','Custom')][string]$Mode='Full',
    [string]$GameName,
    [string]$EngineIniPath,
    [switch]$QuarantineSaves,
    [switch]$PurgeNvidiaCaches,
# legacy blunt flag (still supported)
    [switch]$StopOverlays,
# new granular overlay control
    [ValidateSet('None','HelpersOnly','Aggressive')][string]$OverlayMode = 'HelpersOnly',
    [string[]]$OverlayAllow,
    [switch]$NoBalancedPlan,
    [switch]$NoAMDServiceCheck,
    [switch]$DryRun,
    [switch]$ListGames
)

# Elevate if needed and preserve all flags
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    $argsList = @('-NoProfile','-ExecutionPolicy','Bypass','-File',"$PSCommandPath")
    if ($PSBoundParameters.ContainsKey('Mode'))              { $argsList += @('-Mode', $Mode) }
    if ($PSBoundParameters.ContainsKey('GameName'))          { $argsList += @('-GameName', $GameName) }
    if ($PSBoundParameters.ContainsKey('EngineIniPath'))     { $argsList += @('-EngineIniPath', $EngineIniPath) }
    if ($QuarantineSaves)                                    { $argsList += '-QuarantineSaves' }
    if ($PurgeNvidiaCaches)                                  { $argsList += '-PurgeNvidiaCaches' }
    if ($StopOverlays)                                       { $argsList += '-StopOverlays' }
    if ($PSBoundParameters.ContainsKey('OverlayMode'))       { $argsList += @('-OverlayMode', $OverlayMode) }
    if ($OverlayAllow)                                       { foreach($a in $OverlayAllow){ $argsList += @('-OverlayAllow', $a) } }
    if ($NoBalancedPlan)                                     { $argsList += '-NoBalancedPlan' }
    if ($NoAMDServiceCheck)                                  { $argsList += '-NoAMDServiceCheck' }
    if ($DryRun)                                             { $argsList += '-DryRun' }
    if ($ListGames)                                          { $argsList += '-ListGames' }
    Start-Process PowerShell -Verb RunAs -ArgumentList $argsList
    exit
}

# Load module from local src (avoid any globally installed shadow)
$modulePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'src\UEWorldEntryRepair.psd1'
Import-Module $modulePath -Force

# Forward every provided param to the public entrypoint
Repair-UEWorldEntry @PSBoundParameters
