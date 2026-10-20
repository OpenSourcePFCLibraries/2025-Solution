# Builds and runs the PFC unit tests with the PBUnit framework (tests\framework, a git submodule).
# Run a subset with -Filter, e.g.  -Filter "n_cst_dwsrv_linkage_tests.test_null*"
# Exit code: 0 = all tests passed, 1 = test failures, 2 = build or run problem.
param([string]$Filter)

$root = Split-Path -Parent $PSScriptRoot
$invoke = Join-Path $PSScriptRoot "framework\scripts\Invoke-PBUnit.ps1"
if (-not (Test-Path $invoke)) {
    Write-Host "PBUnit framework not found. Run: git submodule update --init"
    exit 2
}

& $invoke -Project (Join-Path $root "pfc_tests.pbproj") -OutDir (Join-Path $root "build\pfc_tests") -Filter $Filter
exit $LASTEXITCODE