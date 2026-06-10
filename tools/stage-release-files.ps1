# Stages release files into an output folder from a release-files.txt manifest.
#
# Manifest format (tools/release-files.txt):
#   plain line        -> include this file or folder (folders are added recursively)
#   line starting !   -> exclude this path and everything under it (exact path prefix)
#   blank line        -> ignored
#
# Example:
#   cursors/
#   carets/
#   !cursors/ibeam-variants/
#   !carets/variants/
#
# Files are copied into -OutDir preserving their original folder layout, so the
# folder mirrors exactly what gets released. The caller is responsible for
# cleaning -OutDir beforehand.

param(
    [Parameter(Mandatory)][string]$ListFile,
    [Parameter(Mandatory)][string]$OutDir
)

$ErrorActionPreference = 'Stop'

$root = (Get-Location).Path

# Parse the manifest into includes and excludes
$includes = @()
$excludes = @()
foreach ($raw in Get-Content -LiteralPath $ListFile) {
    $line = $raw.Trim()
    if (-not $line) { continue }
    if ($line.StartsWith('!')) {
        $excludes += $line.Substring(1).Trim().TrimEnd('/', '\')
    } else {
        $includes += $line.TrimEnd('/', '\')
    }
}

# Resolve exclude prefixes to absolute paths for reliable matching
$excludeFull = $excludes | ForEach-Object { [IO.Path]::GetFullPath((Join-Path $root $_)) }

function Test-Excluded([string]$path) {
    $full = [IO.Path]::GetFullPath($path)
    $sep = [IO.Path]::DirectorySeparatorChar
    foreach ($ex in $excludeFull) {
        if ($full -eq $ex -or $full.StartsWith($ex + $sep, [StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

# Validate that every include exists before doing any work
foreach ($inc in $includes) {
    if (-not (Test-Path -LiteralPath (Join-Path $root $inc))) {
        Write-Error "Missing file: $inc"
        exit 1
    }
}

# Copy included files into the output folder, applying exclusions and keeping layout
$outFull = [IO.Path]::GetFullPath($OutDir)
New-Item -ItemType Directory -Path $outFull -Force | Out-Null
foreach ($inc in $includes) {
    $src = Join-Path $root $inc
    if (Test-Path -LiteralPath $src -PathType Container) {
        foreach ($file in Get-ChildItem -LiteralPath $src -Recurse -File) {
            if (Test-Excluded $file.FullName) { continue }
            $rel = $file.FullName.Substring($root.Length).TrimStart('\', '/')
            $dest = Join-Path $outFull $rel
            New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
            Copy-Item -LiteralPath $file.FullName -Destination $dest
        }
    } else {
        $dest = Join-Path $outFull $inc
        New-Item -ItemType Directory -Path (Split-Path $dest) -Force | Out-Null
        Copy-Item -LiteralPath $src -Destination $dest
    }
}
