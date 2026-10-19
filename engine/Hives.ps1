# User hive handling.
# Catalog paths use HKCU\...; the engine expands them to every real user profile
# plus the Default user template (so new accounts inherit the setting). This also
# makes the tool work when it runs as SYSTEM (scheduled re-apply), where HKCU is not the user.

$script:MountedHives = @()      # hives we loaded ourselves (must be unloaded)
$script:UserTargets = $null     # cached list of @{ Name; Root; Kind }

function Get-CurrentUserSid {
    return [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
}

function Mount-RegHive {
    param([string]$MountName, [string]$HiveFile)
    $out = & reg.exe load "HKU\$MountName" $HiveFile 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Log DEBUG "reg load $MountName failed: $out"
        return $false
    }
    $script:MountedHives += $MountName
    return $true
}

function Get-UserTargets {
    # Returns @( @{Name=...; Root='HKU\<sid>'; Kind='user'|'default'} )
    if ($null -ne $script:UserTargets) { return $script:UserTargets }
    $targets = @()
    $isAdmin = Test-IsAdmin
    $loaded = @(Get-ChildItem Registry::HKEY_USERS -ErrorAction SilentlyContinue |
            Where-Object { $_.PSChildName -match '^S-1-5-21-\d+-\d+-\d+-\d+$' } |
            ForEach-Object { $_.PSChildName })
    $profiles = @()
    $plKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
    foreach ($k in @(Get-ChildItem $plKey -ErrorAction SilentlyContinue)) {
        if ($k.PSChildName -notmatch '^S-1-5-21-\d+-\d+-\d+-\d+$') { continue }
        $path = (Get-ItemProperty $k.PSPath -ErrorAction SilentlyContinue).ProfileImagePath
        if ($path) { $profiles += @{ Sid = $k.PSChildName; Path = (Expand-EnvPath $path) } }
    }

    if (-not $isAdmin) {
        $sid = Get-CurrentUserSid
        $targets += @{ Name = $sid; Root = "HKU\$sid"; Kind = 'user' }
        $script:UserTargets = $targets
        return $targets
    }

    foreach ($p in $profiles) {
        if ($loaded -contains $p.Sid) {
            $targets += @{ Name = $p.Sid; Root = "HKU\$($p.Sid)"; Kind = 'user' }
            continue
        }
        $nt = Join-Path $p.Path 'NTUSER.DAT'
        if (Test-Path -LiteralPath $nt) {
            $mount = 'WinDebloat_' + ($p.Sid -replace '[^0-9]', '_')
            if (Mount-RegHive -MountName $mount -HiveFile $nt) {
                $targets += @{ Name = $p.Sid; Root = "HKU\$mount"; Kind = 'user' }
            }
            else {
                Write-Log WARN "Could not load hive for $($p.Sid) (profile in use or locked); skipping."
            }
        }
    }
    $defNt = Join-Path $env:SystemDrive 'Users\Default\NTUSER.DAT'
    if (Test-Path -LiteralPath $defNt) {
        if (Mount-RegHive -MountName 'WinDebloat_Default' -HiveFile $defNt) {
            $targets += @{ Name = 'Default'; Root = 'HKU\WinDebloat_Default'; Kind = 'default' }
        }
    }
    $script:UserTargets = $targets
    return $targets
}

function Dismount-UserHives {
    if ($script:MountedHives.Count -eq 0) { $script:UserTargets = $null; return }
    [gc]::Collect(); [gc]::WaitForPendingFinalizers(); [gc]::Collect()
    foreach ($m in $script:MountedHives) {
        $ok = $false
        for ($i = 0; $i -lt 5 -and -not $ok; $i++) {
            & reg.exe unload "HKU\$m" 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { $ok = $true } else { Start-Sleep -Milliseconds 300; [gc]::Collect() }
        }
        if (-not $ok) { Write-Log WARN "Could not unload HKU\$m; it will be released at next logoff/reboot." }
    }
    $script:MountedHives = @()
    $script:UserTargets = $null
}
