New-Item -Path "HKCU:\Software\Microsoft\GameBar" -Force|Out-Null
New-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "GameModeEnabled" -Value 1 -PropertyType DWord -Force|Out-Null
New-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1 -PropertyType DWord -Force|Out-Null
& (Join-Path $PSScriptRoot 'Write-ActionLog.ps1') "Game Mode enabled" "OK"
