# Script action: winget settings.json telemetry.disable=true for the Default user template and every existing profile.
# An existing settings.json is merged (other keys kept; comments are lost, so the original is backed up next to it as
# settings.json.windebloat.bak). A file that cannot be parsed is left alone with a warning.
# NOTE: scriptblocks returned from a script file do not see this file's variables when called later,
# so every block defines its own helpers/constants.

return @{
    Test = {
        param($Action)
        $rel = 'AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json'
        $roots = @((Join-Path $env:SystemDrive 'Users\Default'))
        $plKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
        foreach ($k in @(Get-ChildItem $plKey -ErrorAction SilentlyContinue)) {
            if ($k.PSChildName -notmatch '^S-1-5-21-\d+-\d+-\d+-\d+$') { continue }
            $pp = (Get-ItemProperty $k.PSPath -ErrorAction SilentlyContinue).ProfileImagePath
            if ($pp) { $roots += [Environment]::ExpandEnvironmentVariables($pp) }
        }
        $pending = @(); $prior = @()
        foreach ($r in $roots) {
            if (-not (Test-Path -LiteralPath $r)) { continue }
            $f = Join-Path $r $rel
            $ok = $false
            if (Test-Path -LiteralPath $f) {
                try {
                    $txt = [IO.File]::ReadAllText($f)
                    $clean = ($txt -replace '(?m)^\s*//.*$', '') -replace '(?s)/\*.*?\*/', ''
                    $o = $clean | ConvertFrom-Json
                    if ($o.telemetry -and $o.telemetry.disable -eq $true) { $ok = $true }
                }
                catch { $ok = $false }
            }
            if (-not $ok) { $pending += $r }
        }
        if ($pending.Count -eq 0) { return @{ Status = 'Applied'; Detail = ''; Prior = @() } }
        return @{ Status = 'Pending'; Detail = ("winget telemetry not disabled for " + $pending.Count + " profile(s)"); Prior = @() }
    }
    Apply = {
        param($Action, $Test)
        $rel = 'AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json'
        $roots = @((Join-Path $env:SystemDrive 'Users\Default'))
        $plKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
        foreach ($k in @(Get-ChildItem $plKey -ErrorAction SilentlyContinue)) {
            if ($k.PSChildName -notmatch '^S-1-5-21-\d+-\d+-\d+-\d+$') { continue }
            $pp = (Get-ItemProperty $k.PSPath -ErrorAction SilentlyContinue).ProfileImagePath
            if ($pp) { $roots += [Environment]::ExpandEnvironmentVariables($pp) }
        }
        $utf8 = New-Object Text.UTF8Encoding($false)
        foreach ($r in $roots) {
            if (-not (Test-Path -LiteralPath $r)) { continue }
            $f = Join-Path $r $rel
            try {
                $dir = Split-Path $f -Parent
                if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                if (Test-Path -LiteralPath $f) {
                    $txt = [IO.File]::ReadAllText($f)
                    $clean = ($txt -replace '(?m)^\s*//.*$', '') -replace '(?s)/\*.*?\*/', ''
                    $o = $clean | ConvertFrom-Json
                    if ($o.telemetry -and $o.telemetry.disable -eq $true) { continue }
                    Copy-Item -LiteralPath $f -Destination ($f + '.windebloat.bak') -Force
                    if (-not $o.telemetry) { $o | Add-Member -NotePropertyName telemetry -NotePropertyValue ([pscustomobject]@{ disable = $true }) }
                    elseif ($null -eq $o.telemetry.disable) { $o.telemetry | Add-Member -NotePropertyName disable -NotePropertyValue $true }
                    else { $o.telemetry.disable = $true }
                    [IO.File]::WriteAllText($f, ($o | ConvertTo-Json -Depth 20), $utf8)
                }
                else {
                    [IO.File]::WriteAllText($f, '{"telemetry":{"disable":true}}', $utf8)
                }
            }
            catch { Write-Log WARN "winget settings.json in $r : $($_.Exception.Message)" }
        }
    }
    Undo = {
        param($Action, $Prior)
        $rel = 'AppData\Local\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json'
        $roots = @((Join-Path $env:SystemDrive 'Users\Default'))
        $plKey = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
        foreach ($k in @(Get-ChildItem $plKey -ErrorAction SilentlyContinue)) {
            if ($k.PSChildName -notmatch '^S-1-5-21-\d+-\d+-\d+-\d+$') { continue }
            $pp = (Get-ItemProperty $k.PSPath -ErrorAction SilentlyContinue).ProfileImagePath
            if ($pp) { $roots += [Environment]::ExpandEnvironmentVariables($pp) }
        }
        foreach ($r in $roots) {
            $f = Join-Path $r $rel
            $bak = $f + '.windebloat.bak'
            try {
                if (Test-Path -LiteralPath $bak) { Copy-Item -LiteralPath $bak -Destination $f -Force; Remove-Item -LiteralPath $bak -Force }
                elseif (Test-Path -LiteralPath $f) {
                    $txt = [IO.File]::ReadAllText($f)
                    if (($txt -replace '\s', '') -eq '{"telemetry":{"disable":true}}') { Remove-Item -LiteralPath $f -Force }
                }
            }
            catch { Write-Log WARN "winget settings.json undo in $r : $($_.Exception.Message)" }
        }
    }
}
