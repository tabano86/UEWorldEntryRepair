param($Path,$Section,[string[]]$KeyValues,[switch]$Remove)
$dir=Split-Path $Path -Parent
if(-not(Test-Path $dir)){New-Item -ItemType Directory -Path $dir -Force|Out-Null}
$content=(Test-Path $Path)?(Get-Content -Raw $Path):""
$sec=$Section.Trim('[]')
$pattern="(?ms)^\[$([regex]::Escape($sec))\]\s*(.*?)\s*(?=^\[|$)"
if($Remove){
  if($content -match $pattern){
    $body=([regex]::Match($content,$pattern)).Groups[1].Value -split "(`r`n|`n)"
    $new=$body|Where-Object{ $line=$_; -not ($KeyValues|ForEach-Object{ $k=$_.Split('=')[0]; $line -match "^\s*$([regex]::Escape($k))\s*=" })}
    $repl="[$sec]`r`n"+($new -join "`r`n")
    $updated=[regex]::Replace($content,$pattern,[System.Text.RegularExpressions.MatchEvaluator]{param($m)$repl})
    Set-Content -Path $Path -Value $updated -Encoding utf8
  }
  return
}
if($content -notmatch "(?m)^\[$([regex]::Escape($sec))\]"){
  $out=@()
  if($content.Trim()){ $out+=$content.TrimEnd(),"","[$sec]" } else { $out+="[$sec]" }
  $out+=$KeyValues
  Set-Content -Path $Path -Value ($out -join "`r`n") -Encoding utf8
  return
}
$m=[regex]::Match($content,$pattern)
$body=$m.Groups[1].Value -split "(`r`n|`n)"
$filtered=$body|Where-Object{ $line=$_; -not ($KeyValues|ForEach-Object{ $k=$_.Split('=')[0]; $line -match "^\s*$([regex]::Escape($k))\s*=" })}
$newBody=@($filtered)+$KeyValues
$repl="[$sec]`r`n"+($newBody -join "`r`n")
$updated=[regex]::Replace($content,$pattern,[System.Text.RegularExpressions.MatchEvaluator]{param($m)$repl})
Set-Content -Path $Path -Value $updated -Encoding utf8
