param($Message,$Level='INFO')
$prefix="[$(Get-Date -Format HH:mm:ss)]"
switch($Level){'OK'{$c='Green'}'WARN'{$c='Yellow'}'ERR'{$c='Red'}'STEP'{$c='Cyan'}default{$c='Gray'}}
Write-Host "$prefix [$Level] $Message" -ForegroundColor $c
"$prefix [$Level] $Message" | Out-File -FilePath $script:LogFile -Append -Encoding utf8
