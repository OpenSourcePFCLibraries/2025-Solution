<#
.SYNOPSIS
    Compiles the PFC solution, or one of its projects, incrementally with PBAutoBuild and
    reports the errors, the warnings and how many objects each project recompiled.

.DESCRIPTION
    Runs PBAutoBuild's PBC approach with /c (compile, and save the compiled objects) and /i
    (incremental: only objects that changed, and the objects that depend on them, are
    recompiled):

        pbautobuild250.exe /pbc /c "PFC.pbsln" /i

    It doesn't deploy: no exe or PBD files are created. Use it to check that changes
    compile, for example after editing source outside the PowerBuilder IDE; use
    tests\run_tests.ps1 to build and run the unit tests.

    PBAutoBuild's output is written to build\incremental.log. The script prints a line for
    each project with the number of objects it recompiled, then any errors. Warnings are
    counted; -ShowWarnings lists them.

.PARAMETER Target
    The solution (.pbsln) or project (.pbproj) to compile, relative to the folder that
    contains PFC.pbsln. The default is PFC.pbsln, all of the projects.

.PARAMETER Full
    Compile everything (PBC's /f) instead of incrementally.

.PARAMETER ShowWarnings
    List the warnings as well as the errors.

.PARAMETER PBAutoBuild
    The path to pbautobuild250.exe.

.EXAMPLE
    pwsh -File tools\Build-Incremental.ps1

.EXAMPLE
    pwsh -File tools\Build-Incremental.ps1 -Target "pfc examples.pbproj" -ShowWarnings

.NOTES
    Exit code: 0 = compiled without errors, 1 = compile errors, 2 = PBAutoBuild could not
    run or the target was not found. Close the solution in the PowerBuilder IDE first: if
    both compile at the same time, one of them may fail or overwrite the other's work.
#>
param(
    [string]$Target = "PFC.pbsln",
    [switch]$Full,
    [switch]$ShowWarnings,
    [string]$PBAutoBuild = "C:\Program Files (x86)\Appeon\PowerBuilder 25.0\pbautobuild250.exe"
)

$root = Split-Path -Parent $PSScriptRoot
$targetPath = Join-Path $root $Target
if (-not (Test-Path $targetPath)) {
    Write-Host "Not found: $targetPath"
    exit 2
}
if (-not (Test-Path $PBAutoBuild)) {
    Write-Host "PBAutoBuild not found: $PBAutoBuild (use -PBAutoBuild)"
    exit 2
}

$buildDir = Join-Path $root "build"
New-Item -ItemType Directory -Force $buildDir | Out-Null
$log = Join-Path $buildDir "incremental.log"

# PBAutoBuild wants the file name right after /c, and /i (or /f) after it
$mode = if ($Full) { "/f" } else { "/i" }
$arguments = @("/pbc", "/c", "`"$targetPath`"", $mode)

$kind = if ($Full) { "Full" } else { "Incremental" }
Write-Host "$kind compile of $Target ..."
$timer = [Diagnostics.Stopwatch]::StartNew()
$process = Start-Process $PBAutoBuild -ArgumentList $arguments -WorkingDirectory $root `
    -NoNewWindow -Wait -PassThru -RedirectStandardOutput $log
$seconds = [int]$timer.Elapsed.TotalSeconds

# The log is UTF-16
$lines = [IO.File]::ReadAllText($log, [Text.Encoding]::Unicode) -split "`r?`n"

# Each project starts with a line naming its .pbproj; "1> <file>..." lines are the objects
# the first compile step (abstract syntax tree generation) processed.
$projects = [ordered]@{}
$current = $null
foreach ($line in $lines) {
    if ($line -match '\[Normal\] (.+\.pbproj)\s*$') {
        $current = Split-Path $Matches[1] -Leaf
        $projects[$current] = 0
    }
    elseif ($current -and $line -match '\] 1> .+\.\.\.\s*$') {
        $projects[$current]++
    }
}
# Case-sensitive: PBAutoBuild also writes "[Normal] [ERROR] Compilation failed", a summary
$errors = @($lines | Where-Object { $_ -cmatch '\[Error\]' })
$warnings = @($lines | Where-Object { $_ -cmatch '\[Warning\]' })

foreach ($name in $projects.Keys) {
    $count = $projects[$name]
    $what = if ($count -eq 0) { "up to date" } elseif ($count -eq 1) { "1 object" } else { "$count objects" }
    Write-Host ("  {0,-34} {1}" -f $name, $what)
}

if ($errors.Count -gt 0) {
    Write-Host ""
    Write-Host "Errors:"
    $errors | ForEach-Object { Write-Host ("  " + ($_ -replace '^\S+ \[Error\] ', '')) }
}
if ($ShowWarnings -and $warnings.Count -gt 0) {
    Write-Host ""
    Write-Host "Warnings:"
    $warnings | ForEach-Object { Write-Host ("  " + ($_ -replace '^\S+ \[Warning\] ', '')) }
}

Write-Host ""
Write-Host ("{0} error(s), {1} warning(s), {2}s, PBAutoBuild exit code {3}. Log: {4}" -f `
    $errors.Count, $warnings.Count, $seconds, $process.ExitCode, $log)

if ($errors.Count -gt 0) { exit 1 }
if ($process.ExitCode -ne 0) {
    # Not a compile error that the log names: show the end of the log
    $lines | Where-Object { $_.Trim() -and $_ -notmatch '\.\.\.\s*$' } | Select-Object -Last 15 |
        ForEach-Object { Write-Host "  $_" }
    exit 2
}
exit 0
