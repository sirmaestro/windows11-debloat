<#
.SYNOPSIS
    Engine self-tests. No Pester needed, no elevation needed.
    Writes only to HKCU\Software\WinDebloatSelfTest and %TEMP%\windebloat-selftest.flag, and cleans both up.
    Also validates the real catalog/ and profiles/ (structure only; nothing is applied).
.EXAMPLE
    powershell -NoProfile -File tests\Invoke-Tests.ps1
#>
$ErrorActionPreference = 'Stop'
$script:Root = Split-Path $PSScriptRoot -Parent
$script:EngineRoot = Join-Path $script:Root 'engine'
$script:Quiet = $true
. (Join-Path $script:EngineRoot 'Common.ps1')
. (Join-Path $script:EngineRoot 'Hives.ps1')
. (Join-Path $script:EngineRoot 'TrustedInstaller.ps1')
foreach ($f in (Get-ChildItem (Join-Path $script:EngineRoot 'Actions') -Filter '*.ps1' | Sort-Object Name)) { . $f.FullName }
. (Join-Path $script:EngineRoot 'Catalog.ps1')
. (Join-Path $script:EngineRoot 'Snapshot.ps1')
. (Join-Path $script:EngineRoot 'Commands.ps1')

$script:Pass = 0; $script:Fail = 0
function Check {
    param([string]$Name, [bool]$Cond, [string]$Info = '')
    if ($Cond) { $script:Pass++; Write-Host "  PASS  $Name" -ForegroundColor Green }
    else { $script:Fail++; Write-Host "  FAIL  $Name  $Info" -ForegroundColor Red }
}

$testKey = 'HKCU:\Software\WinDebloatSelfTest'
$flag = Join-Path $env:TEMP 'windebloat-selftest.flag'
function Clean { Remove-Item $testKey -Recurse -Force -ErrorAction SilentlyContinue; Remove-Item $flag -Force -ErrorAction SilentlyContinue }

try {
    Clean
    New-Item $testKey -Force | Out-Null
    New-ItemProperty $testKey -Name 'ToDelete' -Value 7 -PropertyType DWord | Out-Null

    Write-Host '== catalog (fixtures)'
    $env:WINDEBLOAT_CATALOG = Join-Path $PSScriptRoot 'fixtures\catalog'
    $env:WINDEBLOAT_PROFILES = Join-Path $PSScriptRoot 'fixtures\profiles'
    $cat = Get-Catalog -Force
    Check 'fixture catalog loads 5 tweaks' ($cat.Count -eq 5) "got $($cat.Count)"
    $sel = Select-Tweaks -Profile 'selftest'
    Check 'profile wildcard selects all' ($sel.Count -eq 5)
    Check 'phase ordering: test.dword first' ($sel[0].Id -eq 'test.dword')
    $only = Select-Tweaks -Profile 'selftest' -Only 'test.exec,test.del*'
    Check '-Only filters with wildcards' ($only.Count -eq 2)

    Write-Host '== registry set / verify / undo'
    $t1 = $cat['test.dword']
    $st = Get-TweakStatus $t1
    Check 'fresh state is Pending' ($st.Status -eq 'Pending') $st.Status
    foreach ($ar in $st.Actions) { & ("Invoke-Action" + $ar.Action.Type) $ar.Action $ar.Result }
    $st2 = Get-TweakStatus $t1
    Check 'after apply is Applied' ($st2.Status -eq 'Applied') $st2.Status
    $p = Get-ItemProperty $testKey
    Check 'DWord value written' ($p.Flag -eq 1)
    $raw = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey('Software\WinDebloatSelfTest').GetValue('BigDword')
    Check 'DWord 4294967295 stored as 0xFFFFFFFF (-1 as Int32)' ($raw -eq -1)
    Check 'String value written' ($p.Text -eq 'hello')
    Check 'MultiString written' ((@($p.Multi) -join ',') -eq 'a,b')
    Check 'Binary written' (($p.Bin -join ',') -eq '0,1,255')
    # drift: change a value then re-test
    Set-ItemProperty $testKey -Name Flag -Value 0
    Check 'drift detected after external change' ((Get-TweakStatus $t1).Status -eq 'Pending')
    # undo using priors captured BEFORE the first apply (state was absent)
    $i = 0
    foreach ($ar in $st.Actions) { Undo-ActionRegistry $ar.Action $ar.Result.Prior; $i++ }
    $p = Get-ItemProperty $testKey
    Check 'undo removes values that did not exist before' ($null -eq $p.Flag -and $null -eq $p.Text -and $null -eq $p.Bin)

    Write-Host '== registry delete value / undo restores'
    $t2 = $cat['test.delete']
    $s2 = Get-TweakStatus $t2
    Check 'delete: Pending while value exists' ($s2.Status -eq 'Pending')
    Invoke-ActionRegistry $s2.Actions[0].Action $s2.Actions[0].Result
    Check 'delete: value gone -> Applied' ((Get-TweakStatus $t2).Status -eq 'Applied')
    Undo-ActionRegistry $s2.Actions[0].Action $s2.Actions[0].Result.Prior
    Check 'delete undo restores value 7' ((Get-ItemProperty $testKey).ToDelete -eq 7)

    Write-Host '== snapshot JSON round trip'
    $run = New-RunRecord 'selftest'
    Add-RunEntry $run 'test.delete' 0 $s2.Actions[0].Action $s2.Actions[0].Result.Prior
    $back = @(Get-RunRecords) | Where-Object { $_.Run -eq $run.Run } | Select-Object -First 1
    Check 'run record readable' ($null -ne $back -and $back.Entries.Count -eq 1)
    $act = ConvertTo-Hashtable $back.Entries[0].Action
    Check 'action converts back to hashtable' ($act -is [hashtable] -and $act.Op -eq 'DeleteValue')
    Remove-Item (Join-Path $script:RunsDir ($run.Run + '.json')) -Force -ErrorAction SilentlyContinue

    Write-Host '== exec / not-applicable / build gate'
    $t3 = $cat['test.exec']
    Check 'exec Pending first' ((Get-TweakStatus $t3).Status -eq 'Pending')
    $s3 = Get-TweakStatus $t3
    Invoke-ActionExec $s3.Actions[0].Action $s3.Actions[0].Result
    Check 'exec Applied after apply' ((Get-TweakStatus $t3).Status -eq 'Applied')
    Undo-ActionExec $s3.Actions[0].Action $null
    Check 'exec revert runs' (-not (Test-Path $flag))
    Check 'missing service is NotApplicable' ((Get-TweakStatus $cat['test.service-na']).Status -eq 'NotApplicable')
    Check 'build gate skips' ((Get-TweakStatus $cat['test.badbuild']).Status -eq 'SkippedBuild')

    Write-Host '== validation catches bad definitions'
    $bad = @(
        (Test-ActionDefinition @{ Type = 'Registry'; Path = 'HKLM\X'; Name = 'a'; Kind = 'DWord' } 'x')
        (Test-ActionDefinition @{ Type = 'Registry'; Path = 'C:\x'; Name = 'a'; Kind = 'DWord'; Value = 1 } 'x')
        (Test-ActionDefinition @{ Type = 'Service'; Name = 'a'; Start = 'Sometimes' } 'x')
        (Test-ActionDefinition @{ Type = 'Nope' } 'x')
        (Test-ActionDefinition @{ Type = 'Exec'; Apply = '1' } 'x')
    )
    Check 'each malformed action reports a problem' (@($bad | Where-Object { $_ }).Count -ge 5) "got $(@($bad | Where-Object { $_ }).Count)"
    Check 'valid action reports none' (@(Test-ActionDefinition @{ Type = 'Registry'; Path = 'HKCU\Software\x'; Name = 'a'; Kind = 'DWord'; Value = 1 } 'x').Count -eq 0)

    Write-Host '== registry helpers'
    Check 'DWORD 4294967295 -> -1' ((ConvertTo-RegData 'DWord' 4294967295) -eq -1)
    Check 'DWORD 0x7FFFFFFF stays' ((ConvertTo-RegData 'DWord' 2147483647) -eq 2147483647)
    $bin = ConvertTo-RegData 'Binary' '0a-ff'
    Check 'Binary hex parse' ($bin.Length -eq 2 -and $bin[0] -eq 10 -and $bin[1] -eq 255)
    Check 'Binary int-array parse' ((ConvertTo-RegData 'Binary' @(1, 2, 3)).Length -eq 3)
    Check 'HKCU path expands to >=1 target' (@(Resolve-RegPath 'HKCU\Software\x').Count -ge 1)

    Write-Host '== full pipeline: apply -> status -> drift -> apply -DriftOnly -> revert (fake admin, temp state dir)'
    $realRuns = $script:RunsDir; $realState = $script:StateFile; $realTargets = $script:UserTargets
    $tmpData = Join-Path $env:TEMP ('windebloat-test-' + [guid]::NewGuid().ToString('N'))
    $script:DataDir = $tmpData; $script:RunsDir = Join-Path $tmpData 'runs'; $script:LogDir = Join-Path $tmpData 'logs'
    $script:StateFile = Join-Path $tmpData 'state.json'; $script:LogFile = $null
    Initialize-DataDir
    $sid = Get-CurrentUserSid
    $script:UserTargets = @(@{ Name = $sid; Root = "HKU\$sid"; Kind = 'user' })   # never load other hives in tests
    function Test-IsAdmin { return $true }                                         # shadows the real check for this run only
    Remove-Item $testKey -Recurse -Force -ErrorAction SilentlyContinue
    New-Item $testKey -Force | Out-Null; New-ItemProperty $testKey -Name 'ToDelete' -Value 7 -PropertyType DWord | Out-Null
    $env:WINDEBLOAT_CATALOG = Join-Path $PSScriptRoot 'fixtures\catalog'
    $env:WINDEBLOAT_PROFILES = Join-Path $PSScriptRoot 'fixtures\profiles'
    $null = Get-Catalog -Force
    $rc = Invoke-Apply -Profile 'selftest' -Yes -NoExplorerRestart
    Check 'apply returns 0' ($rc -eq 0) "rc=$rc"
    Check 'apply wrote Flag' ((Get-ItemProperty $testKey).Flag -eq 1)
    Check 'apply deleted ToDelete' ($null -eq (Get-ItemProperty $testKey).ToDelete)
    Check 'apply created flag file via Exec' (Test-Path $flag)
    $st = Get-State
    Check 'state records applied tweaks' ($st.Applied.ContainsKey('test.dword') -and $st.Applied.ContainsKey('test.delete') -and $st.Applied.ContainsKey('test.exec'))
    Check 'status clean (no drift)' ((Invoke-Status -Profile 'selftest') -eq 0)
    Set-ItemProperty $testKey -Name Flag -Value 0
    Check 'status reports drift (exit 1)' ((Invoke-Status -Profile 'selftest') -eq 1)
    Check 'apply -DriftOnly repairs only drift' ((Invoke-Apply -Profile 'selftest' -Yes -DriftOnly -NoExplorerRestart) -eq 0 -and (Get-ItemProperty $testKey).Flag -eq 1)
    Check 'revert last run only undoes that run (Flag back to drifted value 0)' ((Invoke-Revert -Run 'last' -Yes) -eq 0 -and (Get-ItemProperty $testKey).Flag -eq 0)
    Check 'second apply did not overwrite the first snapshot' (@(Get-RunRecords).Count -eq 2)
    Check 'revert -Only restores the ORIGINAL state' ((Invoke-Revert -Only 'test.*' -Yes) -eq 0)
    $pp = Get-ItemProperty $testKey
    Check 'revert removed Flag/Text' ($null -eq $pp.Flag -and $null -eq $pp.Text)
    Check 'revert restored ToDelete=7' ($pp.ToDelete -eq 7)
    Check 'revert ran exec Revert (flag file gone)' (-not (Test-Path $flag))
    Remove-Item Function:\Test-IsAdmin -ErrorAction SilentlyContinue
    . (Join-Path $script:EngineRoot 'Common.ps1')                                  # restore the real Test-IsAdmin
    Remove-Item $tmpData -Recurse -Force -ErrorAction SilentlyContinue
    $script:RunsDir = $realRuns; $script:StateFile = $realState; $script:UserTargets = $realTargets

    Write-Host '== real catalog + profiles'
    Remove-Item Env:\WINDEBLOAT_CATALOG, Env:\WINDEBLOAT_PROFILES -ErrorAction SilentlyContinue
    $real = Get-Catalog -Force -Lenient
    Check ("real catalog loads (" + $real.Count + " tweaks)") ($real.Count -ge 0)
    $probs = Invoke-Validate
    Check 'all profile entries resolve to catalog tweaks' ($probs -eq 0) "$probs unresolved"
}
finally {
    Remove-Item Env:\WINDEBLOAT_CATALOG, Env:\WINDEBLOAT_PROFILES -ErrorAction SilentlyContinue
    Clean
    Dismount-UserHives
}
Write-Host ''
Write-Host ("{0} passed, {1} failed" -f $script:Pass, $script:Fail) -ForegroundColor $(if ($script:Fail -eq 0) { 'Green' } else { 'Red' })
exit $(if ($script:Fail -eq 0) { 0 } else { 1 })
