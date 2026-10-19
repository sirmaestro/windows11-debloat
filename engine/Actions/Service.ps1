# Action type: Service
#   @{ Type='Service'; Name='DiagTrack'; Start='Disabled'; StopNow=$true }
# Start: Boot | System | Automatic | AutomaticDelayed | Manual | Disabled
# Written through HKLM\SYSTEM\CurrentControlSet\Services\<Name>\Start (not sc.exe), so it also works for drivers.
# If the service/driver does not exist on this build the action is NotApplicable.

$script:ServiceStartMap = @{ Boot = 0; System = 1; Automatic = 2; AutomaticDelayed = 2; Manual = 3; Disabled = 4 }

function Get-ServiceRegState {
    param([string]$Name)
    $t = @(Resolve-RegPath "HKLM\SYSTEM\CurrentControlSet\Services\$Name")[0]
    $key = $null
    try {
        $key = $t.Base.OpenSubKey($t.Sub, $false)
        if (-not $key) { return $null }
        return @{ Start = $key.GetValue('Start'); Delayed = $key.GetValue('DelayedAutostart') }
    }
    finally { if ($key) { $key.Close() } }
}

function Test-ActionService {
    param([hashtable]$Action)
    $cur = Get-ServiceRegState $Action.Name
    if ($null -eq $cur) { return @{ Status = 'NotApplicable'; Detail = "service $($Action.Name) not present"; Prior = $null } }
    $want = $script:ServiceStartMap[$Action.Start]
    $ok = ([int]$cur.Start -eq $want)
    if ($ok -and $Action.Start -eq 'AutomaticDelayed') { $ok = ([int]$cur.Delayed -eq 1) }
    $prior = @{ Start = [int]$cur.Start; Delayed = $cur.Delayed }
    if ($ok) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
    return @{ Status = 'Pending'; Detail = "$($Action.Name): Start $($cur.Start) -> $want ($($Action.Start))"; Prior = $prior }
}

function Set-ServiceStartValue {
    param([string]$Name, [int]$Start, $Delayed)
    $t = @(Resolve-RegPath "HKLM\SYSTEM\CurrentControlSet\Services\$Name")[0]
    $key = $t.Base.OpenSubKey($t.Sub, $true)
    try {
        $key.SetValue('Start', $Start, [Microsoft.Win32.RegistryValueKind]::DWord)
        if ($null -ne $Delayed) { $key.SetValue('DelayedAutostart', [int]$Delayed, [Microsoft.Win32.RegistryValueKind]::DWord) }
    }
    finally { $key.Close() }
}

function Invoke-ActionService {
    param([hashtable]$Action, $Test)
    $want = $script:ServiceStartMap[$Action.Start]
    $delayed = $null
    if ($Action.Start -eq 'AutomaticDelayed') { $delayed = 1 }
    elseif ($Action.Start -eq 'Automatic') { $delayed = 0 }
    $name = $Action.Name
    try { Set-ServiceStartValue $name $want $delayed }
    catch {
        if (-not (Test-AccessDenied $_)) { throw }
        Write-Log DEBUG "Service $name key is protected; retrying as TrustedInstaller"
        Invoke-AsTrustedInstaller { Set-ServiceStartValue $name $want $delayed }
    }
    if ((Get-Prop $Action 'StopNow' $false) -and $Action.Start -eq 'Disabled') {
        $svc = Get-Service -Name $name -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -eq 'Running' -and $svc.ServiceType -notmatch 'Driver') {
            try { Stop-Service -Name $name -Force -ErrorAction Stop } catch { Write-Log DEBUG "Stop-Service $name : $($_.Exception.Message)" }
        }
    }
}

function Undo-ActionService {
    param([hashtable]$Action, $Prior)
    if ($null -eq $Prior) { return }
    $name = $Action.Name
    $start = [int](Get-Prop $Prior 'Start'); $del = Get-Prop $Prior 'Delayed'
    try { Set-ServiceStartValue $name $start $del }
    catch {
        if (-not (Test-AccessDenied $_)) { throw }
        Invoke-AsTrustedInstaller { Set-ServiceStartValue $name $start $del }
    }
}
