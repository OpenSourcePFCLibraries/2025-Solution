# Builds and runs the PFC unit tests with the PBUnit framework (tests\framework, a git submodule).
# Run a subset with -Filter, e.g.  -Filter "n_cst_dwsrv_linkage_tests.test_null*"
# Run them as a 64-bit exe with -Platform 64 (the results go to build\pfc_tests-x64).
# Exit code: 0 = all tests passed, 1 = test failures, 2 = build or run problem.
param(
    [string]$Filter,
    [ValidateSet("32", "64")]
    [string]$Platform = "32"
)

$root = Split-Path -Parent $PSScriptRoot
$invoke = Join-Path $PSScriptRoot "framework\scripts\Invoke-PBUnit.ps1"
if (-not (Test-Path $invoke)) {
    Write-Host "PBUnit framework not found. Run: git submodule update --init"
    exit 2
}

$options = @{ Project = (Join-Path $root "pfc_tests.pbproj"); OutDir = (Join-Path $root "build\pfc_tests"); Filter = $Filter }
if ($Platform -eq "64") {
    # -Platform needs a framework from after the initial import (git submodule update)
    $options.OutDir += "-x64"
    $options.Platform = "64"
}

& $invoke @options
exit $LASTEXITCODE
