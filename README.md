# UEWorldEntryRepair

One-liner (Borderlands 4, keep Discord, kill overlay helpers only):
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\Run-UEWorldEntryRepair.ps1 -Mode Full -GameName "Borderlands 4" -OverlayMode HelpersOnly
```

# Revert:
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\Run-UEWorldEntryRepair.ps1 -Mode Revert -GameName "Borderlands 4"
```
# List detected UE games:
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\Run-UEWorldEntryRepair.ps1 -ListGames
```
# Point at a specific Engine.ini (optional):
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\Run-UEWorldEntryRepair.ps1 -Mode Full -EngineIniPath "C:\Users\<you>\Documents\My Games\Borderlands 4\Saved\Config\Windows\Engine.ini" -OverlayMode HelpersOnly
```

# Optional game-file compatibility profile (no app killing):
#   None | NoRT | UltraSafe
```powershell
powershell -ExecutionPolicy Bypass -File .\tools\Run-UEWorldEntryRepair.ps1 -Mode Full -GameName "Borderlands 4" -CompatProfile NoRT
```