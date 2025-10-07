function Clear-Paths {
    param(
        [string[]]$Paths,
        [switch]$DryRun,
        [string]$LogFile
    )
    foreach ($p in $Paths) {
        if (Test-Path $p) {
            try {
                if (-not $DryRun) { Remove-Item -Recurse -Force $p -ErrorAction Stop }
                Write-ActionLog -Message "Delete $p" -Level OK -LogFile $LogFile
            } catch {
                Write-ActionLog -Message ("Delete {0} - {1}" -f $p, $_.Exception.Message) -Level WARN -LogFile $LogFile
            }
        } else {
            Write-ActionLog -Message "Delete $p - not found" -Level WARN -LogFile $LogFile
        }
    }
}
