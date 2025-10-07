function Stop-GameOverlays {
    param(
        [ValidateSet('None','HelpersOnly','Aggressive')][string]$Mode = 'HelpersOnly',
        [string[]]$Allow,
        [string]$LogFile
    )

    if ($Mode -eq 'None') {
        Write-ActionLog -Message 'Overlay stop skipped (Mode=None)' -Level INFO -LogFile $LogFile
        return
    }

    $targets =
    if ($Mode -eq 'HelpersOnly') {
        @(
        # NVIDIA
            'NVIDIA Share',            # GeForce overlay
            'NVIDIA Overlay',
            # Steam
            'GameOverlayUI',
            # Discord (overlay-only; leave Discord.exe alone)
            'DiscordHookHelper',
            'DiscordOverlayHost',
            # RTSS / Afterburner overlay
            'RTSS',
            'RTSSHooksLoader64'
        )
    } else {
        @(
        # everything in HelpersOnly...
            'NVIDIA Share','NVIDIA Overlay','GameOverlayUI','DiscordHookHelper','DiscordOverlayHost','RTSS','RTSSHooksLoader64',
            # ...plus heavier hitters (use sparingly)
            'Discord','steam','Overwolf'
        )
    }

    if ($Allow -and $Allow.Count) {
        $allowSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$Allow)
        $targets  = $targets | Where-Object { -not $allowSet.Contains($_) }
    }

    foreach ($name in $targets) {
        Get-Process -Name $name -ErrorAction SilentlyContinue | ForEach-Object {
            try {
                Stop-Process -Id $_.Id -Force -ErrorAction Stop
                Write-ActionLog -Message ("Killed {0}" -f $_.ProcessName) -Level OK -LogFile $LogFile
            } catch {
                Write-ActionLog -Message ("{0} - {1}" -f $_.ProcessName, $_.Exception.Message) -Level WARN -LogFile $LogFile
            }
        }
    }
}
