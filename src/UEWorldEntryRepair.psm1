$script:ModuleRoot = Split-Path -Parent $PSCommandPath
Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Private') -Filter *.ps1 | ForEach-Object { . $_.FullName }
Get-ChildItem -Path (Join-Path $script:ModuleRoot 'Public')  -Filter *.ps1 | ForEach-Object { . $_.FullName }
