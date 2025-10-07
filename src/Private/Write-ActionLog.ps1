function Write-ActionLog {
    param(
        [Parameter(Mandatory=$true)][string]$Message,
        [ValidateSet('INFO','OK','WARN','ERR','STEP')][string]$Level='INFO',
        [string]$LogFile
    )
    if (-not $LogFile) { $LogFile = $script:LogFile }
    if (-not $LogFile) { $LogFile = Join-Path $env:TEMP 'UEWorldEntryRepair_default.log' }

    $prefix = "[{0}]" -f (Get-Date -Format HH:mm:ss)
    switch ($Level) {
        'OK'   { $c='Green' }
        'WARN' { $c='Yellow' }
        'ERR'  { $c='Red' }
        'STEP' { $c='Cyan' }
        default{ $c='Gray' }
    }
    Write-Host "$prefix [$Level] $Message" -ForegroundColor $c
    "$prefix [$Level] $Message" | Out-File -FilePath $LogFile -Append -Encoding utf8
}
