param([switch]$Force)
$projectRoot = Split-Path -Parent $PSScriptRoot
$moduleRoot = Join-Path $projectRoot 'src'
$dest = Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell\Modules\UEWorldEntryRepair'
if(Test-Path $dest -and -not $Force){Write-Host 'UEWorldEntryRepair already installed. Use -Force to overwrite.';exit 0}
if(Test-Path $dest){Remove-Item -Recurse -Force $dest}
New-Item -ItemType Directory -Path $dest -Force|Out-Null
Copy-Item -Path (Join-Path $moduleRoot '*') -Destination $dest -Recurse -Force
Import-Module UEWorldEntryRepair -Force
Write-Host 'UEWorldEntryRepair installed. Usage: Repair-UEWorldEntry -Mode Full -GameName "Borderlands 4"' -ForegroundColor Green
