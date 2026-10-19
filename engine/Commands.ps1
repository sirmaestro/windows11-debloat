# CLI commands: list, validate, plan, apply, status, revert, schedule, updates.

$script:MinBuild = 26100

function Assert-Admin {
    if (-not (Test-IsAdmin)) { throw 'This command must run in an elevated (Administrator) PowerShell.' }
}

function Test-Requirement {
    # Returns $null when satisfied, otherwise a message.
    param([string]$Name)
    switch ($Name) {
        'admin' { if (Test-IsAdmin) { return $null } else { return 'needs an elevated session' } }
        'tamper-off' {
            $tp = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender\Features' -ErrorAction SilentlyContinue).TamperProtection
            if ($tp -in @(1, 5)) { return 'Tamper Protection is ON. Turn it off in Windows Security > Virus & threat protection > Manage settings, then re-run.' }
            return $null
        }
        'no-pending-reboot' {
            if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired') { return 'a reboot is pending; reboot and re-run' }
            return $null
        }
        default { return "unknown requirement '$Name'" }
    }
}

function Wait-TamperProtectionOff {
    # Interactive resolver for the 'tamper-off' requirement. Tamper Protection cannot be turned
    # off by script (Microsoft gates it behind the Windows Security UI), so open that page and wait
    # until the user has switched it off. Returns $true once it reads as OFF, $false if the user
    # skips or the session is non-interactive (e.g. the SYSTEM scheduled task).
    if (-not [Environment]::UserInteractive) { return $false }
    Write-Host ''
    Write-Host 'Tamper Protection must be turned OFF before Microsoft Defender can be disabled.' -ForegroundColor Yellow
    Write-Host 'Opening Windows Security > Virus & threat protection ...' -ForegroundColor Cyan
    $open = {
        try { Start-Process 'windowsdefender://threatsettings' -ErrorAction Stop }
        catch {
            try { Start-Process 'windowsdefender:' -ErrorAction Stop }
            catch { Write-Host 'Could not open Windows Security automatically. Open it from Start, then go to Virus & threat protection > Manage settings.' -ForegroundColor Yellow }
        }
    }
    & $open
    Write-Host 'Under "Virus & threat protection settings" click "Manage settings", then switch Tamper Protection OFF.' -ForegroundColor Cyan
    while ($true) {
        $ans = Read-Host 'Press Enter when Tamper Protection is OFF (or type SKIP to leave Defender enabled)'
        if ($ans -ceq 'SKIP') { Write-Log WARN 'Tamper Protection left ON by user; sec.defender-disable will be skipped.'; return $false }
        if (-not (Test-Requirement 'tamper-off')) { Write-Host 'Tamper Protection is now OFF - continuing.' -ForegroundColor Green; return $true }
        Write-Host 'Tamper Protection still reads as ON (it can take a moment to apply). Re-opening the page - try again.' -ForegroundColor Yellow
        & $open
    }
}

function Get-TweakStatus {
    param($Tweak)
    $b = Get-BuildNumber
    $builds = Get-Prop $Tweak 'Builds'
    $min = Get-Prop $builds 'Min'; $max = Get-Prop $builds 'Max'
    if (($min -and $b -lt $min) -or ($max -and $b -gt $max)) {
        return @{ Status = 'SkippedBuild'; Actions = @(); Detail = "build $b outside [$min..$max]" }
    }
    $results = @(); $i = 0
    foreach ($a in @($Tweak.Actions)) {
        try { $r = & ("Test-Action" + $a.Type) $a }
        catch { $r = @{ Status = 'Unknown'; Detail = $_.Exception.Message; Prior = $null } }
        $results += @{ Index = $i; Action = $a; Result = $r }
        $i++
    }
    # An action flagged Optional (value Windows protects on some builds) never makes the tweak count as pending.
    $sts = @($results | ForEach-Object {
            if ((Get-Prop $_.Action 'Optional' $false) -and $_.Result.Status -eq 'Pending') { 'Applied' } else { $_.Result.Status }
        })
    if ($sts -contains 'Pending') { $status = 'Pending' }
    elseif ($sts -contains 'Unknown') { $status = 'Unknown' }
    elseif (($sts | Where-Object { $_ -ne 'NotApplicable' }).Count -eq 0) { $status = 'NotApplicable' }
    else { $status = 'Applied' }
    return @{ Status = $status; Actions = $results; Detail = '' }
}

function Write-StatusLine {
    param([string]$Status, $Tweak, [string]$Extra = '')
    $tag = switch ($Status) {
        'Applied' { 'OK     ' } 'Pending' { 'PENDING' } 'Unknown' { 'UNKNOWN' } 'NotApplicable' { 'N/A    ' }
        'SkippedBuild' { 'BUILD  ' } 'Drift' { 'DRIFT  ' } 'NotApplied' { 'NOT SET' } default { $Status }
    }
    $color = switch ($Status) {
        'Applied' { 'Green' } 'Pending' { 'Yellow' } 'Drift' { 'Red' } 'Unknown' { 'Magenta' } default { 'DarkGray' }
    }
    $risk = Get-Prop $Tweak 'Risk' '?'
    $line = '[{0}] {1,-44} {2,-4} {3}' -f $tag, $Tweak.Id, $risk, $Tweak.Name
    if ($Extra) { $line += "  :: $Extra" }
    Write-Host $line -ForegroundColor $color
    if ($script:LogFile) { try { Add-Content -LiteralPath $script:LogFile -Value $line -Encoding UTF8 } catch { } }
}

function Invoke-List {
    param([string]$Profile, [string[]]$Only, [string[]]$Category)
    $tweaks = Select-Tweaks -Profile $Profile -Only $Only -Category $Category
    foreach ($t in $tweaks) {
        '{0,-44} {1,-4} p{2,-3} {3}' -f $t.Id, $t.Risk, (Get-Prop $t 'Phase' 20), $t.Name
    }
    Write-Host ("{0} tweak(s)" -f $tweaks.Count)
}

function Invoke-Validate {
    $cat = Get-Catalog -Lenient -Force
    Write-Host ("Catalog: {0} tweaks in {1} file(s)." -f $cat.Count, (Get-CatalogFiles).Count)
    $bad = 0
    foreach ($pf in @(Get-ChildItem (Get-ProfilesDir) -Filter *.psd1 -ErrorAction SilentlyContinue)) {
        $def = Import-PowerShellDataFile -LiteralPath $pf.FullName
        $missing = @()
        foreach ($pat in @($def.Tweaks)) { if (@($cat.Keys | Where-Object { $_ -like $pat }).Count -eq 0) { $missing += $pat } }
        Write-Host ("Profile {0}: {1} entries, {2} unresolved" -f $pf.BaseName, @($def.Tweaks).Count, $missing.Count)
        foreach ($m in $missing) { Write-Host "   unresolved: $m" -ForegroundColor Yellow; $bad++ }
    }
    return $bad
}

function Invoke-Plan {
    param([string]$Profile, [string[]]$Only, [string[]]$Category, [switch]$Detail, [switch]$PendingOnly)
    $tweaks = Select-Tweaks -Profile $Profile -Only $Only -Category $Category
    if (-not (Test-IsAdmin)) { Write-Log WARN 'Not elevated: HKLM reads work, but capability/feature/bcdedit/all-users Appx state is incomplete and other users'' hives are not inspected.' }
    $counts = @{}
    foreach ($t in $tweaks) {
        $st = Get-TweakStatus $t
        $counts[$st.Status] = 1 + [int]$counts[$st.Status]
        if ($PendingOnly -and $st.Status -in @('Applied', 'NotApplicable', 'SkippedBuild')) { continue }
        Write-StatusLine $st.Status $t
        if ($Detail -or $st.Status -eq 'Unknown') {
            foreach ($a in $st.Actions) {
                if ($a.Result.Status -in @('Pending', 'Unknown') -and $a.Result.Detail) { Write-Host ("            - {0}" -f $a.Result.Detail) -ForegroundColor DarkGray }
            }
        }
    }
    Write-Host ''
    Write-Host ("Summary: " + (($counts.GetEnumerator() | Sort-Object Name | ForEach-Object { "$($_.Name)=$($_.Value)" }) -join '  '))
    return 0
}

function Invoke-Apply {
    param([string]$Profile, [string[]]$Only, [string[]]$Category, [switch]$Yes, [switch]$DriftOnly, [switch]$NoExplorerRestart, [switch]$Force)
    Assert-Admin
    $b = Get-BuildNumber
    if ($b -lt $script:MinBuild -and -not $Force) { throw "Build $b is older than the supported minimum $script:MinBuild (Windows 11 24H2). Use -Force to override." }
    $tweaks = Select-Tweaks -Profile $Profile -Only $Only -Category $Category
    $state = Get-State
    if ($DriftOnly) { $tweaks = @($tweaks | Where-Object { $state.Applied.ContainsKey($_.Id) }) }

    $work = @(); $already = 0; $skipped = 0
    foreach ($t in $tweaks) {
        $st = Get-TweakStatus $t
        switch ($st.Status) {
            'Pending' { $work += @{ Tweak = $t; Status = $st } }
            'Applied' { $already++; $state.Applied[$t.Id] = @{ Time = (Get-Date).ToString('o'); Run = 'verified'; Profile = $Profile } }
            default { $skipped++ }
        }
    }
    Write-Log INFO ("{0} tweak(s) pending, {1} already applied, {2} skipped (n/a/unknown/build)." -f $work.Count, $already, $skipped)
    if ($work.Count -eq 0) { Save-State $state; return 0 }

    $high = @($work | Where-Object { $_.Tweak.Risk -eq 'high' })
    if (-not $Yes) {
        Write-Host ''
        Write-Host ("About to apply {0} tweak(s):" -f $work.Count) -ForegroundColor Cyan
        foreach ($w in $work) { Write-StatusLine 'Pending' $w.Tweak }
        if ($high.Count -gt 0) { Write-Host ("`n{0} HIGH-risk tweak(s) included: {1}" -f $high.Count, (($high | ForEach-Object { $_.Tweak.Id }) -join ', ')) -ForegroundColor Red }
        Write-Host "`nA restore point / VM checkpoint is recommended before continuing." -ForegroundColor Yellow
        $ans = Read-Host "Type YES to apply"
        if ($ans -cne 'YES') { Write-Log WARN 'Aborted by user.'; return 2 }
    }

    $run = New-RunRecord $Profile
    $fail = 0; $reboot = @(); $explorer = $false
    foreach ($w in $work) {
        $t = $w.Tweak
        $unmet = @()
        foreach ($rq in @(Get-Prop $t 'Requires' @())) {
            $m = Test-Requirement $rq
            if (-not $m) { continue }
            # Tamper Protection is the one requirement the user can clear mid-run: prompt and wait.
            # Skip the prompt under -Yes (unattended/automation) and fall through to the normal skip.
            if ($rq -eq 'tamper-off' -and -not $Yes -and (Wait-TamperProtectionOff)) { continue }
            $unmet += $m
        }
        if ($unmet.Count -gt 0) { Write-Log ERROR "$($t.Id): requirement not met: $($unmet -join '; ')"; $fail++; continue }
        Write-Log INFO "applying $($t.Id) - $($t.Name)"
        $ok = $true
        foreach ($ar in $w.Status.Actions) {
            if ($ar.Result.Status -ne 'Pending') { continue }
            try {
                & ("Invoke-Action" + $ar.Action.Type) $ar.Action $ar.Result
            }
            catch {
                if (Get-Prop $ar.Action 'Optional' $false) {
                    Write-Log WARN "$($t.Id) action #$($ar.Index) ($($ar.Action.Type)) skipped, Windows protects it on this build: $($_.Exception.Message)"
                }
                else {
                    $ok = $false
                    Write-Log ERROR "$($t.Id) action #$($ar.Index) ($($ar.Action.Type)) failed: $($_.Exception.Message)"
                }
            }
            finally {
                Add-RunEntry $run $t.Id $ar.Index $ar.Action $ar.Result.Prior
            }
        }
        $after = Get-TweakStatus $t
        if ($ok -and $after.Status -in @('Applied', 'NotApplicable')) {
            Write-Log OK "$($t.Id)"
            $state.Applied[$t.Id] = @{ Time = (Get-Date).ToString('o'); Run = $run.Run; Profile = $Profile }
            if (Get-Prop $t 'Reboot' $false) { $reboot += $t.Id }
            if (Get-Prop $t 'RestartExplorer' $false) { $explorer = $true }
        }
        else {
            $fail++
            Write-Log WARN "$($t.Id): not verified after apply (status $($after.Status)). A reboot or elevated/TrustedInstaller step may be required."
        }
    }
    Save-State $state
    if ($explorer -and -not $NoExplorerRestart -and [Environment]::UserInteractive -and $env:USERNAME -ne "$($env:COMPUTERNAME)`$") {
        Write-Log INFO 'Restarting Explorer to pick up shell changes.'
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    }
    Write-Host ''
    Write-Log INFO ("Run {0}: {1} applied/verified, {2} failed. Snapshot: {3}" -f $run.Run, ($work.Count - $fail), $fail, (Join-Path $script:RunsDir ($run.Run + '.json')))
    if ($reboot.Count -gt 0) { Write-Log WARN ("Reboot recommended for: " + ($reboot -join ', ')) }
    if ($fail -gt 0) { return 1 } else { return 0 }
}

function Invoke-Status {
    param([string]$Profile, [string[]]$Only, [string[]]$Category)
    $state = Get-State
    $tweaks = Select-Tweaks -Profile $Profile -Only $Only -Category $Category
    $drift = 0; $ok = 0; $notset = 0
    foreach ($t in $tweaks) {
        $st = Get-TweakStatus $t
        $was = $state.Applied.ContainsKey($t.Id)
        if ($st.Status -eq 'Pending' -and $was) { $drift++; Write-StatusLine 'Drift' $t (($st.Actions | Where-Object { $_.Result.Status -eq 'Pending' } | ForEach-Object { $_.Result.Detail }) -join '; ') }
        elseif ($st.Status -eq 'Pending') { $notset++; Write-StatusLine 'NotApplied' $t }
        elseif ($st.Status -eq 'Applied') { $ok++ }
    }
    Write-Host ''
    Write-Host ("Status: {0} in place, {1} DRIFTED since last apply, {2} not applied." -f $ok, $drift, $notset)
    if ($drift -gt 0) { Write-Host "Run: debloat.ps1 apply -DriftOnly" -ForegroundColor Yellow; return 1 }
    return 0
}

function Invoke-Revert {
    param([string]$Run, [string[]]$Only, [switch]$Yes)
    Assert-Admin
    $runs = @(Get-RunRecords)
    if ($runs.Count -eq 0) { Write-Log WARN 'No snapshots found.'; return 0 }
    $entries = @()
    if ($Only) {
        $flat = @($Only | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
        $done = @{}
        # OLDEST snapshot first: it holds the state from before this tool ever touched the tweak
        # (later runs, e.g. drift repairs, only captured the already-modified state).
        foreach ($r in @($runs | Sort-Object { $_.Run })) {
            $mine = @($r.Entries | Where-Object { $e = $_; ($flat | Where-Object { $e.Tweak -like $_ }).Count -gt 0 })
            foreach ($tid in @($mine | ForEach-Object { $_.Tweak } | Select-Object -Unique)) {
                if ($done.ContainsKey($tid)) { continue }
                $done[$tid] = $true
                $entries += @($mine | Where-Object { $_.Tweak -eq $tid })
            }
        }
    }
    else {
        $target = if ($Run -and $Run -ne 'last') { $runs | Where-Object { $_.Run -eq $Run } | Select-Object -First 1 } else { $runs[0] }
        if (-not $target) { throw "Run '$Run' not found." }
        $entries = @($target.Entries)
    }
    if ($entries.Count -eq 0) { Write-Log WARN 'Nothing to revert for that selection.'; return 0 }
    $ids = @($entries | ForEach-Object { $_.Tweak } | Select-Object -Unique)
    Write-Host ("Reverting {0} action(s) across {1} tweak(s): {2}" -f $entries.Count, $ids.Count, ($ids -join ', ')) -ForegroundColor Cyan
    if (-not $Yes) { if ((Read-Host 'Type YES to revert') -cne 'YES') { Write-Log WARN 'Aborted.'; return 2 } }
    $state = Get-State; $fail = 0
    # newest actions first
    $rev = @($entries | Sort-Object { $_.Tweak }, @{ Expression = { $_.Index }; Descending = $true })
    foreach ($e in $rev) {
        $a = ConvertTo-Hashtable $e.Action
        try { & ("Undo-Action" + $e.Type) $a $e.Prior; Write-Log OK "reverted $($e.Tweak) #$($e.Index) ($($e.Type))" }
        catch { $fail++; Write-Log ERROR "revert $($e.Tweak) #$($e.Index) failed: $($_.Exception.Message)" }
    }
    foreach ($id in $ids) { if ($state.Applied.ContainsKey($id)) { $state.Applied.Remove($id) } }
    Save-State $state
    if ($fail -gt 0) { return 1 } else { return 0 }
}

function Invoke-Schedule {
    param([string]$Profile, [switch]$Remove)
    Assert-Admin
    $name = 'WinDebloat-Reapply'
    if ($Remove) {
        Unregister-ScheduledTask -TaskName $name -Confirm:$false -ErrorAction SilentlyContinue
        Write-Log OK "Removed scheduled task $name"
        return 0
    }
    if (-not $Profile) { throw 'schedule needs -Profile <name>' }
    $script = Join-Path $script:Root 'debloat.ps1'
    $arg = "-NoProfile -ExecutionPolicy Bypass -File `"$script`" apply -Profile $Profile -DriftOnly -Yes -NoExplorerRestart -Quiet"
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $arg
    $trg1 = New-ScheduledTaskTrigger -AtStartup
    $trg1.Delay = 'PT3M'
    $trg2 = New-ScheduledTaskTrigger -AtLogOn
    $principal = New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -ExecutionTimeLimit (New-TimeSpan -Hours 1)
    Register-ScheduledTask -TaskName $name -Action $action -Trigger @($trg1, $trg2) -Principal $principal -Settings $settings -Force | Out-Null
    Write-Log OK "Registered $name (runs 'apply -Profile $Profile -DriftOnly' as SYSTEM at startup and logon). Keep this folder in place: $script:Root"
    return 0
}

function Invoke-Updates {
    param([ValidateSet('pause', 'resume', 'status')][string]$Mode)
    $tw = (Get-Catalog).Values | Where-Object { $_.Id -eq 'upd.pause-2038' } | Select-Object -First 1
    switch ($Mode) {
        'status' {
            $v = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings' -ErrorAction SilentlyContinue).PauseUpdatesExpiryTime
            if ($v) { Write-Host "Windows Update is PAUSED until $v" } else { Write-Host 'Windows Update is not paused.' }
            return 0
        }
        'pause' { return (Invoke-Apply -Only 'upd.pause-2038' -Yes) }
        'resume' {
            Assert-Admin
            $def = & (Join-Path $script:Root 'engine\scripts\UpdatePause.ps1')
            & $def.Undo @{ } $null
            Write-Log OK 'Update pause cleared. Run Windows Update now; afterwards run: debloat.ps1 apply -DriftOnly, then: debloat.ps1 updates pause'
            return 0
        }
    }
}
