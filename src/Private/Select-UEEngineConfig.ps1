function Select-UEEngineConfig {
    param(
        [string]$GamesRoot,
        [string]$GameName,
        [string]$EngineIniPath,
        [switch]$List
    )

    if ($EngineIniPath) { return [pscustomobject]@{ Game=$GameName; Ini=$EngineIniPath } }
    if ($GameName)      { return [pscustomobject]@{ Game=$GameName; Ini=(Join-Path $GamesRoot "$GameName\Saved\Config\Windows\Engine.ini") } }

    $cands = Get-ChildItem -Path $GamesRoot -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $p = Join-Path $_.FullName "Saved\Config\Windows\Engine.ini"
        if (Test-Path $p) { [pscustomobject]@{ Game=$_.Name; Ini=$p; When=(Get-Item $_.FullName).LastWriteTimeUtc } }
    } | Sort-Object When -Descending

    if ($List) { $cands | Select-Object Game,Ini; return $null }
    if ($cands -and $cands[0]) { return [pscustomobject]@{ Game=$cands[0].Game; Ini=$cands[0].Ini } }
    return $null
}
