# Action types: Appx, Capability, Feature (all need an elevated session for full results)

# ---------- Appx ----------
#   @{ Type='Appx'; Name='Microsoft.BingNews' }          removes installed (all users) + provisioned packages; wildcards allowed
# Not reversible by the tool (reinstall from the Store / winget). Pair with a Registry 'Deprovisioned' tweak to stop re-install.

function Get-AppxMatches {
    param([string]$Name)
    $installed = @()
    $prov = @()
    if (Test-IsAdmin) {
        $installed = @(Get-AppxPackage -AllUsers -Name $Name -ErrorAction SilentlyContinue)
        if ($null -eq $script:ProvCache) { $script:ProvCache = @(Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue) }
        $prov = @($script:ProvCache | Where-Object { $_.DisplayName -like $Name })
    }
    else {
        $installed = @(Get-AppxPackage -Name $Name -ErrorAction SilentlyContinue)
    }
    return @{ Installed = $installed; Provisioned = $prov }
}

function Test-ActionAppx {
    param([hashtable]$Action)
    $m = Get-AppxMatches $Action.Name
    $n = $m.Installed.Count + $m.Provisioned.Count
    if ($n -eq 0) { return @{ Status = 'Applied'; Detail = ''; Prior = @() } }
    $names = @($m.Installed | ForEach-Object { $_.PackageFullName }) + @($m.Provisioned | ForEach-Object { 'provisioned:' + $_.PackageName })
    return @{ Status = 'Pending'; Detail = ($Action.Name + ' installed'); Prior = $names }
}

$script:DeprovisionedKey = 'SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned'

function Get-AppxFamilies {
    param($Found)
    $f = @($Found.Installed | ForEach-Object { $_.PackageFamilyName }) + @($Found.Provisioned | ForEach-Object { "$($_.DisplayName)_$($_.PublisherId)" })
    return @($f | Where-Object { $_ } | Sort-Object -Unique)
}

function Remove-DeprovisionedMarker {
    # Returns $true if a marker existed and was removed.
    param([string]$Family)
    $sub = "$script:DeprovisionedKey\$Family"
    $k = [Microsoft.Win32.Registry]::LocalMachine.OpenSubKey($sub)
    if (-not $k) { return $false }
    $k.Close()
    [Microsoft.Win32.Registry]::LocalMachine.DeleteSubKeyTree($sub, $false)
    return $true
}

function Invoke-ActionAppx {
    param([hashtable]$Action, $Test)
    $m = Get-AppxMatches $Action.Name
    # A Deprovisioned\<family> key that exists BEFORE the removal (appx.deprovision-markers, or an app reinstalled by a
    # feature update) makes Remove-AppxPackage -AllUsers fail with 0x80070005 and leaves DISM reporting
    # "cannot find the file/path". Lift the marker for the removal; it is put back (Windows also re-creates it).
    $lifted = @(foreach ($f in (Get-AppxFamilies $m)) { if (Remove-DeprovisionedMarker $f) { $f } })
    try {
        $script:ProvCache = $null
        $m = Get-AppxMatches $Action.Name
        # Deprovision first (as Winhance / revision-tool do): Remove-AppxPackage -AllUsers also deprovisions on 24H2+,
        # so running DISM afterwards targets a package that is already gone.
        foreach ($p in $m.Provisioned) {
            try { Remove-AppxProvisionedPackage -Online -PackageName $p.PackageName -ErrorAction Stop | Out-Null }
            catch { Write-Log WARN "Remove-AppxProvisionedPackage $($p.DisplayName): $($_.Exception.Message)" }
        }
        # Get-AppxPackage -AllUsers returns one object per user profile; also skip anything removed as a side effect above.
        foreach ($p in @($m.Installed | Sort-Object PackageFullName -Unique)) {
            if (-not (Get-AppxPackage -AllUsers -Name $p.Name -ErrorAction SilentlyContinue | Where-Object { $_.PackageFullName -eq $p.PackageFullName })) { continue }
            try { Remove-AppxPackage -Package $p.PackageFullName -AllUsers -ErrorAction Stop }
            catch { Write-Log WARN "Remove-AppxPackage $($p.Name): $($_.Exception.Message)" }
        }
    }
    finally {
        foreach ($f in $lifted) { [Microsoft.Win32.Registry]::LocalMachine.CreateSubKey("$script:DeprovisionedKey\$f").Close() }
        $script:ProvCache = $null
    }
}

function Undo-ActionAppx {
    param([hashtable]$Action, $Prior)
    Write-Log WARN "Appx '$($Action.Name)' cannot be restored by the tool; reinstall it from the Microsoft Store (winget install --id <StoreId> -s msstore)."
}

# ---------- Capability ----------
#   @{ Type='Capability'; Name='Browser.InternetExplorer'; State='NotPresent' }      (prefix match on capability name)

function Get-CapabilityList {
    if ($null -eq $script:CapCache) { $script:CapCache = @(Get-WindowsCapability -Online -ErrorAction SilentlyContinue) }
    return $script:CapCache
}

function Test-ActionCapability {
    param([hashtable]$Action)
    if (-not (Test-IsAdmin)) { return @{ Status = 'Unknown'; Detail = 'needs admin'; Prior = @() } }
    $hits = @(Get-CapabilityList | Where-Object { $_.Name -like ($Action.Name + '*') })
    if ($hits.Count -eq 0) { return @{ Status = 'NotApplicable'; Detail = 'capability not present on this build'; Prior = @() } }
    $installed = @($hits | Where-Object { $_.State -eq 'Installed' })
    $names = @($installed | ForEach-Object { $_.Name })
    if ($installed.Count -gt 0) { return @{ Status = 'Pending'; Detail = ($names -join ','); Prior = $names } }
    return @{ Status = 'Applied'; Detail = ''; Prior = @() }
}

function Invoke-ActionCapability {
    param([hashtable]$Action, $Test)
    foreach ($n in @($Test.Prior)) { Remove-WindowsCapability -Online -Name $n -ErrorAction Stop | Out-Null }
    $script:CapCache = $null
}

function Undo-ActionCapability {
    param([hashtable]$Action, $Prior)
    foreach ($n in @($Prior)) { Add-WindowsCapability -Online -Name $n -ErrorAction Continue | Out-Null }
    $script:CapCache = $null
}

# ---------- Feature ----------
#   @{ Type='Feature'; Name='MicrosoftWindowsPowerShellV2Root'; State='Disabled' }   (State: Disabled | Enabled)
#   Option: Remove=$true  (also remove payload when disabling, e.g. Recall)

function Get-FeatureList {
    if ($null -eq $script:FeatCache) { $script:FeatCache = @(Get-WindowsOptionalFeature -Online -ErrorAction SilentlyContinue) }
    return $script:FeatCache
}

function Test-ActionFeature {
    param([hashtable]$Action)
    if (-not (Test-IsAdmin)) { return @{ Status = 'Unknown'; Detail = 'needs admin'; Prior = $null } }
    $f = Get-FeatureList | Where-Object { $_.FeatureName -eq $Action.Name } | Select-Object -First 1
    if (-not $f) { return @{ Status = 'NotApplicable'; Detail = 'feature not present'; Prior = $null } }
    $cur = [string]$f.State
    $wantEnabled = ($Action.State -eq 'Enabled')
    $isEnabled = ($cur -eq 'Enabled')
    $isRemoved = ($cur -eq 'DisabledWithPayloadRemoved')
    $ok = if ($wantEnabled) { $isEnabled } elseif ((Get-Prop $Action 'Remove' $false)) { $isRemoved } else { -not $isEnabled }
    $prior = @{ State = $cur }
    if ($ok) { return @{ Status = 'Applied'; Detail = ''; Prior = $prior } }
    return @{ Status = 'Pending'; Detail = "$($Action.Name): $cur -> $($Action.State)"; Prior = $prior }
}

function Invoke-ActionFeature {
    param([hashtable]$Action, $Test)
    if ($Action.State -eq 'Enabled') {
        Enable-WindowsOptionalFeature -Online -FeatureName $Action.Name -NoRestart -ErrorAction Stop | Out-Null
    }
    else {
        if (Get-Prop $Action 'Remove' $false) { Disable-WindowsOptionalFeature -Online -FeatureName $Action.Name -Remove -NoRestart -ErrorAction Stop | Out-Null }
        else { Disable-WindowsOptionalFeature -Online -FeatureName $Action.Name -NoRestart -ErrorAction Stop | Out-Null }
    }
    $script:FeatCache = $null
}

function Undo-ActionFeature {
    param([hashtable]$Action, $Prior)
    if ($Prior -and (Get-Prop $Prior 'State') -eq 'Enabled') {
        Enable-WindowsOptionalFeature -Online -FeatureName $Action.Name -NoRestart -ErrorAction Continue | Out-Null
    }
    $script:FeatCache = $null
}
