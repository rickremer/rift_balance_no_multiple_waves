$rblogspath = (Join-Path -Path $env:USERPROFILE -ChildPath 'Documents\The Riftbreaker' )
$taillog = 'exor_logs.txt'

Get-Content -Path ( Join-Path -Path $rblogspath -ChildPath $taillog ) -Wait
