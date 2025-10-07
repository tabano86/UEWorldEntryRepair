function Get-UEGames{
  [CmdletBinding()]
  param()
  $root=Join-Path $env:USERPROFILE 'Documents\My Games'
  Get-ChildItem -Path $root -Directory -ErrorAction SilentlyContinue|ForEach-Object{
    $p=Join-Path $_.FullName 'Saved\Config\Windows\Engine.ini'
    if(Test-Path $p){[pscustomobject]@{Game=$_.Name;EngineIni=$p}}
  }
}
Export-ModuleMember -Function Get-UEGames
