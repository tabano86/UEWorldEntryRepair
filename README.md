# UEWorldEntryRepair
Unreal world-entry crash repair. Disables DLSS/Frame Gen/FSR3 at the config level, purges UE/NVIDIA caches, quarantines saves, enforces sensible Windows gaming settings, and emits a JSON report.

## Quick Start
1) Extract
2) Right-click `tools\Run-UEWorldEntryRepair.ps1` → Run with PowerShell
3) Example:
```
powershell -ExecutionPolicy Bypass -File .\tools\Run-UEWorldEntryRepair.ps1 -Args -Mode Full -GameName "Borderlands 4"
```

## Commands
- `Repair-UEWorldEntry`
- `Get-UEGames`

## Modes
- Full
- Lite
- Revert
- Custom

## Flags
- `-GameName "Borderlands 4"` or `-EngineIniPath "C:\Users\...\Engine.ini"`
- `-QuarantineSaves`
- `-PurgeNvidiaCaches`
- `-StopOverlays`
- `-NoBalancedPlan`
- `-NoAMDServiceCheck`
- `-DryRun`
- `-ListGames`

## Output
- Log: `%TEMP%\UEWorldEntryRepair_*.log`
- Report JSON: `Documents\My Games\<Game>\Saved\ueworldentry_backup_*\UEWorldEntryRepair_*.json`
