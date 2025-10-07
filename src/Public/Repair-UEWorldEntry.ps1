function Repair-UEWorldEntry {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [string]$GameName,
        [string]$EngineIniPath,
        [ValidateSet('Full','Lite','Revert','Custom')][string]$Mode='Full',
        [switch]$QuarantineSaves,
        [switch]$PurgeNvidiaCaches,
    # deprecated blunt flag (kept for compat); prefer OverlayMode
        [switch]$StopOverlays,
        [ValidateSet('None','HelpersOnly','Aggressive')][string]$OverlayMode = 'HelpersOnly',
        [string[]]$OverlayAllow,
        [switch]$NoBalancedPlan,
        [switch]$NoAMDServiceCheck,
        [switch]$DryRun,
        [switch]$ListGames
    )

    Set-StrictMode -Version Latest
    $ts = Get-Date -Format yyyyMMdd_HHmmss
    $global:ErrorActionPreference = 'Stop'
    $gamesRoot = Join-Path $env:USERPROFILE 'Documents\My Games'
    $script:LogFile = Join-Path $env:TEMP ("UEWorldEntryRepair_" + $ts + ".log")

    $pick = Select-UEEngineConfig -GamesRoot $gamesRoot -GameName $GameName -EngineIniPath $EngineIniPath -List:$ListGames
    if ($ListGames) { return }
    if (-not $pick) { Write-ActionLog -Message 'Engine.ini not found. Use -GameName or -EngineIniPath.' -Level ERR -LogFile $script:LogFile; throw 'Engine.ini not found.' }

    $GameName = $pick.Game
    $ini = $pick.Ini
    if (-not (Test-Path $ini)) { Write-ActionLog -Message ("Engine.ini does not exist: {0}" -f $ini) -Level ERR -LogFile $script:LogFile; throw 'Invalid Engine.ini path.' }

    $savedRoot = Split-Path (Split-Path (Split-Path $ini -Parent) -Parent) -Parent
    $backupDir = Join-Path $savedRoot ("ueworldentry_backup_" + $ts)
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

    Write-ActionLog -Message ("Target {0}" -f $GameName) -Level STEP -LogFile $script:LogFile
    Write-ActionLog -Message $ini -Level OK -LogFile $script:LogFile

    # Mode presets (less destructive defaults)
    if ($Mode -eq 'Full') {
        $QuarantineSaves   = $true
        $PurgeNvidiaCaches = $true
        if (-not $PSBoundParameters.ContainsKey('OverlayMode') -and -not $PSBoundParameters.ContainsKey('StopOverlays')) {
            # Default to HelpersOnly for Full; old -StopOverlays flips to Aggressive below
            $OverlayMode = 'HelpersOnly'
        }
    }

    # Back-compat: if user passed -StopOverlays (legacy), treat as Aggressive unless OverlayMode explicitly set
    if ($StopOverlays -and -not $PSBoundParameters.ContainsKey('OverlayMode')) {
        $OverlayMode = 'Aggressive'
    }

    $keys = @(
        'r.NGX.DLSS.Enable=0',
        'r.NGX.DLSSG.Enable=0',
        'r.Streamline.Enable=0',
        'r.FidelityFX.FSR3=0'
    )

    $bak = "$ini.bak.$ts"
    if (Test-Path $ini) { Copy-Item $ini $bak -Force; Write-ActionLog -Message ("Backup {0}" -f $bak) -Level OK -LogFile $script:LogFile }

    if ($Mode -eq 'Revert') {
        Write-ActionLog -Message 'Revert overrides' -Level STEP -LogFile $script:LogFile
        Set-IniValues -Path $ini -Section 'SystemSettings' -KeyValues $keys -Remove
        Write-ActionLog -Message 'Overrides removed' -Level OK -LogFile $script:LogFile
    } else {
        Write-ActionLog -Message 'Apply overrides' -Level STEP -LogFile $script:LogFile
        Set-IniValues -Path $ini -Section 'SystemSettings' -KeyValues $keys
        Write-ActionLog -Message 'DLSS/FG/FSR3 disabled' -Level OK -LogFile $script:LogFile
    }

    Write-ActionLog -Message 'Purge UE caches' -Level STEP -LogFile $script:LogFile
    $shader = Join-Path $savedRoot 'ShaderCache'
    $pso    = Join-Path $savedRoot 'PipelineCaches'
    $ddc    = Join-Path $savedRoot 'DerivedDataCache'
    Clear-Paths -Paths @($shader,$pso,$ddc) -DryRun:$DryRun -LogFile $script:LogFile

    if ($QuarantineSaves) {
        Write-ActionLog -Message 'Quarantine saves' -Level STEP -LogFile $script:LogFile
        $saves = Join-Path $savedRoot 'SaveGames'
        if (Test-Path $saves) {
            $dest = Join-Path $backupDir 'SaveGames'
            if (-not $DryRun) { Move-Item $saves $dest -Force }
            Write-ActionLog -Message ("{0} -> {1}" -f $saves,$dest) -Level OK -LogFile $script:LogFile
        } else {
            Write-ActionLog -Message 'SaveGames not found' -Level WARN -LogFile $script:LogFile
        }
    }

    if ($PurgeNvidiaCaches) {
        Write-ActionLog -Message 'Purge NVIDIA caches' -Level STEP -LogFile $script:LogFile
        $dx = Join-Path $env:LOCALAPPDATA 'NVIDIA\DXCache'
        $gl = Join-Path $env:LOCALAPPDATA 'NVIDIA\GLCache'
        $nv = 'C:\ProgramData\NVIDIA Corporation\NV_Cache'
        Clear-Paths -Paths @($dx,$gl,$nv) -DryRun:$DryRun -LogFile $script:LogFile
    }

    if (-not $NoBalancedPlan) {
        Write-ActionLog -Message 'Power plan' -Level STEP -LogFile $script:LogFile
        if (-not $DryRun) { Set-BalancedPowerPlan -LogFile $script:LogFile } else { Write-ActionLog -Message 'Power plan unchanged (DryRun)' -Level WARN -LogFile $script:LogFile }
    }

    Write-ActionLog -Message 'Game Mode' -Level STEP -LogFile $script:LogFile
    if (-not $DryRun) { Enable-GameMode -LogFile $script:LogFile } else { Write-ActionLog -Message 'Game Mode unchanged (DryRun)' -Level WARN -LogFile $script:LogFile }

    if (-not $NoAMDServiceCheck) {
        Write-ActionLog -Message 'AMD 3D V-Cache service' -Level STEP -LogFile $script:LogFile
        if (-not $DryRun) { Ensure-AMD3DVCacheService -Name 'amd3dvcacheSvc' -LogFile $script:LogFile } else { Write-ActionLog -Message 'Service unchecked (DryRun)' -Level WARN -LogFile $script:LogFile }
    }

    if ($OverlayMode -ne 'None') {
        Write-ActionLog -Message ("Stop overlays (Mode={0})" -f $OverlayMode) -Level STEP -LogFile $script:LogFile
        if (-not $DryRun) { Stop-GameOverlays -Mode $OverlayMode -Allow $OverlayAllow -LogFile $script:LogFile } else { Write-ActionLog -Message 'Overlays untouched (DryRun)' -Level WARN -LogFile $script:LogFile }
    }

    $sys    = Get-SystemSnapshot
    $report = Join-Path $backupDir ("UEWorldEntryRepair_" + $ts + ".json")
    $summary = [pscustomobject]@{
        Timestamp = $ts
        Game      = $GameName
        EngineIni = $ini
        SavedRoot = $savedRoot
        BackupDir = $backupDir
        Mode      = $Mode
        Flags     = [pscustomobject]@{
            QuarantineSaves   = [bool]$QuarantineSaves
            PurgeNvidiaCaches = [bool]$PurgeNvidiaCaches
            OverlayMode       = $OverlayMode
            OverlayAllow      = $OverlayAllow
            NoBalancedPlan    = [bool]$NoBalancedPlan
            NoAMDServiceCheck = [bool]$NoAMDServiceCheck
            DryRun            = [bool]$DryRun
        }
        System    = $sys
        Log       = $script:LogFile
    }
    $summary | ConvertTo-Json -Depth 6 | Out-File -FilePath $report -Encoding utf8

    [pscustomobject]@{
        Game      = $GameName
        EngineIni = $ini
        SavedRoot = $savedRoot
        Backup    = $backupDir
        Log       = $script:LogFile
        Report    = $report
        GPU       = $sys.GPU
        Driver    = $sys.GPUDriver
        CPU       = $sys.CPU
        OS        = $sys.OS
    }
}
Export-ModuleMember -Function Repair-UEWorldEntry
