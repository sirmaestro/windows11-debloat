<#
.SYNOPSIS
    Windows 11 (24H2+) debloat / tweak CLI. Declarative catalog, snapshots, drift detection.

.DESCRIPTION
    debloat.ps1 <command> [options]

    list      [-Profile P] [-Only ids] [-Category pfx]      list catalog tweaks
    validate                                                  check catalog + profiles for errors
    plan      [-Profile P] [-Only ids] [-Detail]            dry run: shows what would change (never writes)
    apply     [-Profile P] [-Only ids] [-Yes] [-DriftOnly]  apply pending tweaks (needs admin); snapshots first
    status    [-Profile P]                                   report tweaks that Windows reverted (drift)
    revert    [-Run <id|last>] [-Only ids] [-Yes]           restore the state captured before apply
    schedule  -Profile P | -Remove                           run 'apply -DriftOnly' at startup/logon as SYSTEM
    updates   pause | resume | status                        pause Windows Update to 2038 / clear the pause

    Ids accept wildcards, e.g. -Only 'priv.*,svc.diagtrack'. -Category takes the id prefix (priv, svc, appx...).
    Typical update cycle:  updates resume  ->  run Windows Update  ->  apply -DriftOnly  ->  updates pause
#>
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [ValidateSet('help', 'list', 'validate', 'plan', 'apply', 'status', 'revert', 'schedule', 'updates')]
    [string]$Command = 'help',
    [Parameter(Position = 1)][string]$Arg,
    [string]$Profile,
    [string[]]$Only,
    [string[]]$Category,
    [string]$Run,
    [switch]$Yes,
    [switch]$DriftOnly,
    [switch]$Detail,
    [switch]$PendingOnly,
    [switch]$NoExplorerRestart,
    [switch]$Force,
    [switch]$Remove,
    [switch]$Quiet
)

$ErrorActionPreference = 'Stop'
$script:Root = $PSScriptRoot
$script:EngineRoot = Join-Path $PSScriptRoot 'engine'

. (Join-Path $script:EngineRoot 'Common.ps1')
. (Join-Path $script:EngineRoot 'Hives.ps1')
. (Join-Path $script:EngineRoot 'TrustedInstaller.ps1')
foreach ($f in (Get-ChildItem (Join-Path $script:EngineRoot 'Actions') -Filter '*.ps1' | Sort-Object Name)) { . $f.FullName }
. (Join-Path $script:EngineRoot 'Catalog.ps1')
. (Join-Path $script:EngineRoot 'Snapshot.ps1')
. (Join-Path $script:EngineRoot 'Commands.ps1')

$script:Quiet = [bool]$Quiet
$code = 0
try {
    try { Initialize-DataDir }
    catch {
        # not elevated / ProgramData not writable: fall back to a per-user location for logs
        $script:DataDir = Join-Path $env:LOCALAPPDATA 'WinDebloat'
        $script:RunsDir = Join-Path $script:DataDir 'runs'
        $script:LogDir = Join-Path $script:DataDir 'logs'
        $script:StateFile = Join-Path $script:DataDir 'state.json'
        Initialize-DataDir
    }
    switch ($Command) {
        'help' { Get-Help $PSCommandPath -Detailed | Out-String | Write-Host }
        'list' { Invoke-List -Profile $Profile -Only $Only -Category $Category }
        'validate' { $bad = Invoke-Validate; if ($bad -gt 0) { $code = 1 } }
        'plan' { $code = Invoke-Plan -Profile $Profile -Only $Only -Category $Category -Detail:$Detail -PendingOnly:$PendingOnly }
        'apply' { $code = Invoke-Apply -Profile $Profile -Only $Only -Category $Category -Yes:$Yes -DriftOnly:$DriftOnly -NoExplorerRestart:$NoExplorerRestart -Force:$Force }
        'status' { $code = Invoke-Status -Profile $Profile -Only $Only -Category $Category }
        'revert' { $code = Invoke-Revert -Run $(if ($Run) { $Run } else { $Arg }) -Only $Only -Yes:$Yes }
        'schedule' { $code = Invoke-Schedule -Profile $Profile -Remove:$Remove }
        'updates' {
            if (-not $Arg) { throw "updates needs: pause | resume | status" }
            $code = Invoke-Updates -Mode $Arg
        }
    }
}
catch {
    Write-Log ERROR $_.Exception.Message
    if ($env:WINDEBLOAT_DEBUG) { Write-Host $_.ScriptStackTrace -ForegroundColor DarkGray }
    $code = 1
}
finally {
    Dismount-UserHives
}
exit $code
