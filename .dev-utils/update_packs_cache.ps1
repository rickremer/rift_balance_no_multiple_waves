$DebugPreference = "Continue"
Write-Output 'Re-Extracting all RiftBreaker packs...'
Write-Verbose '  assuming from Steam...'
$rborigpacksdir = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'Steam\steamapps\common\Riftbreaker\packs'
Write-Debug '  Game files source := ' + $rborigpacksdir
Write-Verbose "    can't proceed if no source files!"
if ( ! ( Test-Path -Path $rborigpacksdir -PathType Container )) 
{ 
    Write-Error ( '  Fatal Error: RiftBreaker Packs directory not found!' )
    exit 1
}
else { Write-Debug '  exists.' }

function Test-ExistDir {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        [string]$DirPath
    )

    Write-Verbose -Message "Confirming existence of directory: $DirPath"
    if (! (Test-Path -Path $DirPath -PathType Container )) 
    { 
        Write-Debug '  no, so creating...'
        md $DirPath 
    }
    else { Write-Debug '  exists.' }
}

$CacheMaster = 'D:\localtemp\riftbreaker_cache'
Write-Verbose -Message "Define the local working cache master location as $CacheMaster"
Write-Debug -Message '  $CacheMaster := ' + $CacheMaster 
Test-ExistDir $CacheMaster -Verbose

$cachepacksdir = Join-Path -Path $CacheMaster -Childpath 'packs'
Write-Verbose -Message "Define a stable subdirectory to contain the copied packs files as $cachepacksdir"
Write-Verbose -Message "  Note: no automatic update of content here!"
Write-Debug '  $cachepacksdir := ' + $cachepacksdir 
Test-ExistDir $cachepacksdir -Verbose

$packsunziptmpdir = Join-Path -Path $CacheMaster -ChildPath 'unzipped_latest'
Write-Verbose -Message "\nDefine a (final) directory target for latest files from re-extracted packs."
Write-Verbose -Message "  WARNING: All existing content will be deleted!"
Write-Debug -Message '  $packsunziptmpdir (temp location for unzipping packs) := ' + $packsunziptmpdir
if ( Test-Path -Path $packsunziptmpdir -PathType Container ) 
{     
    Remove-Item $packsunziptmpdir -Recurse -Verbose
    #$dirwip = Join-Path -Path $packsunziptmpdir -ChildPath '*'
    #if ( Test-Path -Path $dirwip -PathType Container ) 
    #{
    #    Write-Debug ("  About to empty '" + $dirwip + "'...")
    #    Remove-Item -Path $dirwip -Recurse -WhatIf
    #}
    #else { Write-Debug '  exists and empty.' }
}
Test-ExistDir $packsunziptmpdir -Verbose

Write-Verbose "\nCollect all pack zips from game dir."
$zips = Get-ChildItem -Path $rborigpacksdir -Filter "*.zip" -Recurse
$zips | ForEach-Object {
    $zpath = $_.FullName
    #$zpath = $_.DirectoryName
    $lensubdir = $_.DirectoryName.Length - ($rborigpacksdir.Length +1)
    $dest = "_tmp_"
    if ( $lensubdir -gt 0 )
    {
        Join-Path -Path $dest -ChildPath ( $_.DirectoryName.Substring( $rborigpacksdir.Length +1, $lensubdir))
    }

    #$_StartIndex = $rborigpacksdir.Length +1
    #$_Length = $zpath.Length - $_StartIndex - 4
    #$_Length = $zpath.Length - $_StartIndex
    #if ( 0 -lt $_Length )
    #{
    #    $dest = $zpath.Substring($_StartIndex, $_Length)
    #}
    #else { $dest = "" }
    #$dest = Join-Path -Path $packsunziptmpdir -ChildPath $dest
    #$dest = Join-Path -Path $packsunziptmpdir -ChildPath ( Join-Path -Path "_tmp_" -ChildPath $dest )
    #$dest = Join-Path -Path $packsunziptmpdir -ChildPath "_tmp_"
    $dest = Join-Path -Path $packsunziptmpdir -ChildPath $dest

    Expand-Archive -Path "$zpath" -DestinationPath "$dest"

    #$rcfrom = Join-Path -Path $packsunziptmpdir -ChildPath "_tmp_"
    #robocopy "$rcfrom" "$packsunziptmpdir" /s /xo /move
    robocopy "$dest" "$packsunziptmpdir" /s /xo /move
    if ( Test-Path -Path $dest -PathType Container ) 
    {
        Remove-Item -Path ( Join-Path -Path $dest -ChildPath "*" ) -Recurse
    }
}    