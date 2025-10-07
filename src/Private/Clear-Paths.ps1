function Clear-Paths {
    param(
        [string[]]$Paths,
        [switch]$DryRun,
        [string]$LogFile,
        [string[]]$ExcludeExtensions = @(),   # e.g. '.nvph'
        [switch]$SkipLocked = $true
    )

    function Test-FileLocked {
        param([string]$Path)
        try {
            $fs = [System.IO.File]::Open($Path, 'Open', 'ReadWrite', 'None')
            $fs.Close()
            return $false
        } catch { return $true }
    }

    foreach ($p in $Paths) {
        if (-not (Test-Path $p)) {
            Write-ActionLog -Message "Delete $p - not found" -Level WARN -LogFile $LogFile
            continue
        }

        $item = Get-Item $p -ErrorAction SilentlyContinue
        $files = @()
        if ($item -and $item.PSIsContainer) {
            $files = Get-ChildItem -Path $p -Recurse -Force -File -ErrorAction SilentlyContinue
        } elseif ($item) {
            $files = ,$item
        }

        foreach ($f in $files) {
            if ($ExcludeExtensions -and ($ExcludeExtensions -contains $f.Extension)) {
                Write-ActionLog -Message ("Skip {0} (excluded)" -f $f.FullName) -Level WARN -LogFile $LogFile
                continue
            }
            if ($SkipLocked -and (Test-FileLocked -Path $f.FullName)) {
                Write-ActionLog -Message ("Skip {0} - locked" -f $f.FullName) -Level WARN -LogFile $LogFile
                continue
            }
            try {
                if (-not $DryRun) { Remove-Item -Force $f.FullName -ErrorAction Stop }
                Write-ActionLog -Message ("Delete {0}" -f $f.FullName) -Level OK -LogFile $LogFile
            } catch {
                Write-ActionLog -Message ("Delete {0} - {1}" -f $f.FullName, $_.Exception.Message) -Level WARN -LogFile $LogFile
            }
        }

        # Try to prune emptied directories
        if ($item -and $item.PSIsContainer) {
            Get-ChildItem -Path $p -Recurse -Directory -Force -ErrorAction SilentlyContinue |
                    Sort-Object FullName -Descending | ForEach-Object {
                try {
                    if (-not $DryRun) { Remove-Item $_.FullName -Force -ErrorAction Stop }
                } catch { }
            }
            # do not Remove-Item $p; we keep the container to avoid prompts when excluded/locked files remain
        }
    }
}
