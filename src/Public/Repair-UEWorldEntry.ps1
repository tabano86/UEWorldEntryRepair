function Repair-UEWorldEntry{
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [string]$GameName,
    [string]$EngineIniPath,
    [ValidateSet('Full','Lite','Revert','Custom')][string]$Mode='Full',
    [switch]$QuarantineSaves,
    [switch]$PurgeNvidiaCaches,
    [switch]$StopOverlays,
    [switch]$NoBalancedPlan,
    [switch]$NoAMDServiceCheck,
    [switch]$DryRun,
    [switch]$ListGames
  )
  Set-StrictMode -Version Latest
  $ts=Get-Date -Format yyyyMMdd_HHmmss
  $global:ErrorActionPreference='Stop'
  $gamesRoot=Join-Path $env:USERPROFILE 'Documents\My Games'
  $script:LogFile=Join-Path $env:TEMP ("UEWorldEntryRepair_"+$ts+".log")
  $pick=(Join-Path $PSScriptRoot '..\Private\Select-UEEngineConfig.ps1')
  $log=(Join-Path $PSScriptRoot '..\Private\Write-ActionLog.ps1')
  $iniPick=& $pick $gamesRoot $GameName $EngineIniPath $ListGames
  if($ListGames){return}
  if(-not $iniPick){& $log 'Engine.ini not found. Use -GameName or -EngineIniPath.' 'ERR';throw 'Engine.ini not found.'}
  $GameName=$iniPick.Game
  $ini=$iniPick.Ini
  if(-not (Test-Path $ini)){& $log "Engine.ini path does not exist: $ini" 'ERR';throw 'Invalid Engine.ini path.'}
  $savedRoot=Split-Path (Split-Path (Split-Path $ini -Parent) -Parent) -Parent
  $backupDir=Join-Path $savedRoot ("ueworldentry_backup_"+$ts)
  New-Item -ItemType Directory -Path $backupDir -Force|Out-Null
  & $log "Target $GameName" 'STEP'
  & $log $ini 'OK'
  if($Mode -eq 'Full'){ $QuarantineSaves=$true;$PurgeNvidiaCaches=$true;$StopOverlays=$true }
  $keys=@('r.NGX.DLSS.Enable=0','r.NGX.DLSSG.Enable=0','r.Streamline.Enable=0','r.FidelityFX.FSR3=0')
  $upd=(Join-Path $PSScriptRoot '..\Private\Set-IniValues.ps1')
  $bak="$ini.bak.$ts"
  if(Test-Path $ini){Copy-Item $ini $bak -Force; & $log "Backup $bak" 'OK'}
  if($Mode -eq 'Revert'){
    & $log 'Revert overrides' 'STEP'
    & $upd $ini 'SystemSettings' $keys -Remove
    & $log 'Overrides removed' 'OK'
  } else {
    & $log 'Apply overrides' 'STEP'
    & $upd $ini 'SystemSettings' $keys
    & $log 'DLSS/FG/FSR3 disabled' 'OK'
  }
  & $log 'Purge UE caches' 'STEP'
  $shader=Join-Path $savedRoot 'ShaderCache'
  $pso=Join-Path $savedRoot 'PipelineCaches'
  $ddc=Join-Path $savedRoot 'DerivedDataCache'
  & (Join-Path $PSScriptRoot '..\Private\Clear-Paths.ps1') @($shader,$pso,$ddc) $DryRun
  if($QuarantineSaves){
    & $log 'Quarantine saves' 'STEP'
    $saves=Join-Path $savedRoot 'SaveGames'
    if(Test-Path $saves){
      $dest=Join-Path $backupDir 'SaveGames'
      if(-not $DryRun){Move-Item $saves $dest -Force}
      & $log "$saves → $dest" 'OK'
    } else {
      & $log 'SaveGames not found' 'WARN'
    }
  }
  if($PurgeNvidiaCaches){
    & $log 'Purge NVIDIA caches' 'STEP'
    $dx=Join-Path $env:LOCALAPPDATA 'NVIDIA\DXCache'
    $gl=Join-Path $env:LOCALAPPDATA 'NVIDIA\GLCache'
    $nv='C:\ProgramData\NVIDIA Corporation\NV_Cache'
    & (Join-Path $PSScriptRoot '..\Private\Clear-Paths.ps1') @($dx,$gl,$nv) $DryRun
  }
  if(-not $NoBalancedPlan){
    & $log 'Power plan' 'STEP'
    if(-not $DryRun){& (Join-Path $PSScriptRoot '..\Private\Set-BalancedPowerPlan.ps1')}
  }
  & $log 'Game Mode' 'STEP'
  if(-not $DryRun){& (Join-Path $PSScriptRoot '..\Private\Enable-GameMode.ps1')}
  if(-not $NoAMDServiceCheck){
    & $log 'AMD 3D V-Cache service' 'STEP'
    if(-not $DryRun){& (Join-Path $PSScriptRoot '..\Private\Ensure-AMD3DVCacheService.ps1') 'amd3dvcacheSvc'}
  }
  if($StopOverlays){
    & $log 'Stop overlays' 'STEP'
    if(-not $DryRun){& (Join-Path $PSScriptRoot '..\Private\Stop-GameOverlays.ps1') @('NVIDIA Share','NVIDIA Overlay','Discord','steam')}
  }
  $sys=& (Join-Path $PSScriptRoot '..\Private\Get-SystemSnapshot.ps1')
  $report=Join-Path $backupDir ("UEWorldEntryRepair_"+$ts+".json")
  $summary=[pscustomobject]@{
    Timestamp=$ts
    Game=$GameName
    EngineIni=$ini
    SavedRoot=$savedRoot
    BackupDir=$backupDir
    Mode=$Mode
    Flags=[pscustomobject]@{
      QuarantineSaves=[bool]$QuarantineSaves
      PurgeNvidiaCaches=[bool]$PurgeNvidiaCaches
      StopOverlays=[bool]$StopOverlays
      NoBalancedPlan=[bool]$NoBalancedPlan
      NoAMDServiceCheck=[bool]$NoAMDServiceCheck
      DryRun=[bool]$DryRun
    }
    System=$sys
    Log=$script:LogFile
  }
  $summary|ConvertTo-Json -Depth 6|Out-File -FilePath $report -Encoding utf8
  [pscustomobject]@{
    Game=$GameName
    EngineIni=$ini
    SavedRoot=$savedRoot
    Backup=$backupDir
    Log=$script:LogFile
    Report=$report
    GPU=$sys.GPU
    Driver=$sys.GPUDriver
    CPU=$sys.CPU
    OS=$sys.OS
  }
}
Export-ModuleMember -Function Repair-UEWorldEntry
