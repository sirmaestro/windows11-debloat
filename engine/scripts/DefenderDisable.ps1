# Script action: disable Microsoft Defender (reversible; files stay on disk).
# Re-implementation of revision-tool's `security defender disable` WITHOUT the signed Revision CBS package
# (that package physically removes components and cannot be reproduced; see PLAN.md section 7).
#
# Sequence (from revision-tool, security_service.dart):
#   1. policy values  HKLM\SOFTWARE\Policies\Microsoft\Windows Defender : DisableAntiSpyware=1, DisableAntiVirus=1,
#                     ...\Real-Time Protection : DisableRealtimeMonitoring=1  ->  gpupdate  ->  MpCmdRun -RemoveDefinitions -All
#   2. as TrustedInstaller  HKLM\SOFTWARE\Microsoft\Windows Defender : DisableAntiSpyware=1, DisableAntiVirus=1
#   3. repeat step 1  (after the Jan-2026 cumulative updates gpupdate strips the policy value when
#                      security-intelligence updates are installed; writing both locations again re-syncs them)
#   4. as TrustedInstaller  HKLM\SYSTEM\CurrentControlSet\Services\MDCoreSvc\Start = 4
# Requires Tamper Protection OFF (cannot be turned off by script). Requires an elevated session.
# Not verified on 24H2/25H2 outside the reference projects - test in a VM first.
# Scriptblocks define their own constants (see UpdatePause.ps1 note).

return @{
    Test = {
        param($Action)
        $pol = 'HKLM\SOFTWARE\Policies\Microsoft\Windows Defender'
        $core = 'HKLM\SOFTWARE\Microsoft\Windows Defender'
        $items = @(
            @{ P = $pol; N = 'DisableAntiSpyware'; V = 1 }
            @{ P = $pol; N = 'DisableAntiVirus'; V = 1 }
            @{ P = "$pol\Real-Time Protection"; N = 'DisableRealtimeMonitoring'; V = 1 }
            @{ P = $core; N = 'DisableAntiSpyware'; V = 1 }
            @{ P = $core; N = 'DisableAntiVirus'; V = 1 }
            @{ P = 'HKLM\SYSTEM\CurrentControlSet\Services\MDCoreSvc'; N = 'Start'; V = 4 }
        )
        $prior = @(); $ok = $true; $detail = @()
        # If the Defender service is gone (component removal), there is nothing to disable.
        $svc = @(Resolve-RegPath 'HKLM\SYSTEM\CurrentControlSet\Services\WinDefend')[0]
        $k = $null
        try { $k = $svc.Base.OpenSubKey($svc.Sub, $false) } finally { if ($k) { $k.Close() } }
        foreach ($i in $items) {
            $t = @(Resolve-RegPath $i.P)[0]
            $cur = Read-RegTarget $t $i.N
            $prior += @{ Path = $i.P; Name = $i.N; Existed = $cur.ValueExists; Data = $cur.Data }
            if ($i.P -like '*MDCoreSvc' -and -not $cur.KeyExists) { continue }
            if (-not $cur.ValueExists -or [int]$cur.Data -ne $i.V) { $ok = $false; $detail += "$($i.P)\$($i.N) != $($i.V)" }
        }
        if (-not $k) { return @{ Status = 'Applied'; Detail = 'WinDefend service not present'; Prior = $prior } }
        if ($ok) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
        return @{ Status = 'Pending'; Detail = ($detail -join '; '); Prior = $prior }
    }

    Apply = {
        param($Action, $Test)
        $polBlock = {
            $pol = 'HKLM\SOFTWARE\Policies\Microsoft\Windows Defender'
            foreach ($i in @(
                    @{ P = $pol; N = 'DisableAntiSpyware' }
                    @{ P = $pol; N = 'DisableAntiVirus' }
                    @{ P = "$pol\Real-Time Protection"; N = 'DisableRealtimeMonitoring' })) {
                $t = @(Resolve-RegPath $i.P)[0]
                $key = $t.Base.CreateSubKey($t.Sub)
                try { $key.SetValue($i.N, 1, [Microsoft.Win32.RegistryValueKind]::DWord) } finally { $key.Close() }
            }
        }
        $applyPolicy = {
            & $polBlock
            & gpupdate.exe /Target:Computer /Force 2>&1 | Out-Null
            $mp = Join-Path (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows Defender' -ErrorAction SilentlyContinue).InstallLocation 'MpCmdRun.exe'
            if (-not (Test-Path $mp)) { $mp = Join-Path $env:ProgramFiles 'Windows Defender\MpCmdRun.exe' }
            if (Test-Path $mp) { Start-Process -FilePath $mp -ArgumentList '-RemoveDefinitions -All' -NoNewWindow -Wait -ErrorAction SilentlyContinue }
        }
        # Real-time protection off first when Tamper Protection is already off.
        try { Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop } catch { Write-Log DEBUG "Set-MpPreference: $($_.Exception.Message)" }
        Get-Process -Name SecHealthUI -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

        & $applyPolicy
        Invoke-AsTrustedInstaller {
            $t = @(Resolve-RegPath 'HKLM\SOFTWARE\Microsoft\Windows Defender')[0]
            $key = $t.Base.CreateSubKey($t.Sub)
            try {
                $key.SetValue('DisableAntiSpyware', 1, [Microsoft.Win32.RegistryValueKind]::DWord)
                $key.SetValue('DisableAntiVirus', 1, [Microsoft.Win32.RegistryValueKind]::DWord)
            }
            finally { $key.Close() }
        }
        & $applyPolicy   # Jan-2026 workaround: re-sync both locations
        Invoke-AsTrustedInstaller {
            $t = @(Resolve-RegPath 'HKLM\SYSTEM\CurrentControlSet\Services\MDCoreSvc')[0]
            $key = $t.Base.OpenSubKey($t.Sub, $true)
            if ($key) { try { $key.SetValue('Start', 4, [Microsoft.Win32.RegistryValueKind]::DWord) } finally { $key.Close() } }
        }
        # gpupdate may have stripped the policy value again; write it one last time WITHOUT gpupdate.
        & $polBlock
    }

    Undo = {
        param($Action, $Prior)
        # Restore every value to what it was before the tool changed it.
        foreach ($e in @($Prior)) {
            if ($null -eq $e) { continue }
            $path = Get-Prop $e 'Path'; $name = Get-Prop $e 'Name'
            $isCore = ($path -eq 'HKLM\SOFTWARE\Microsoft\Windows Defender' -or $path -like '*MDCoreSvc')
            $existed = Get-Prop $e 'Existed' $false; $data = Get-Prop $e 'Data'
            $block = {
                $t = @(Resolve-RegPath $path)[0]
                if ($existed) {
                    $key = $t.Base.CreateSubKey($t.Sub)
                    try { $key.SetValue($name, [int]$data, [Microsoft.Win32.RegistryValueKind]::DWord) } finally { $key.Close() }
                }
                else {
                    $key = $t.Base.OpenSubKey($t.Sub, $true)
                    if ($key) { try { $key.DeleteValue($name, $false) } finally { $key.Close() } }
                }
            }
            if ($isCore) { Invoke-AsTrustedInstaller $block } else { & $block }
        }
        & gpupdate.exe /Target:Computer /Force 2>&1 | Out-Null
        Write-Log WARN 'Defender policy/service values restored. Reboot, then check Windows Security.'
    }
}
