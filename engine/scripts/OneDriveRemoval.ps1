# Script action: uninstall OneDrive for every user (ported from the ReviOS playbook's ONED.cmd).
#   - runs OneDriveSetup.exe /uninstall (per-user uninstall paths, then System32 / SysWOW64)
#   - removes the per-user Run 'OneDrive' value and Uninstall\OneDriveSetup.exe key (handled by Registry actions in the
#     catalog entry for HKCU targets; this script also cleans AppData and Start Menu links)
#   - deletes each user's AppData\Local\Microsoft\OneDrive and the Start Menu OneDrive.lnk
# User data in %USERPROFILE%\OneDrive is NEVER deleted.
# Appx, nav-pane CLSID, leftover folders are separate actions in the catalog entry.
# Not reversible by the tool (reinstall: winget install Microsoft.OneDrive).

return @{
    Test = {
        param($Action)
        $setups = @("$env:SystemRoot\System32\OneDriveSetup.exe", "$env:SystemRoot\SysWOW64\OneDriveSetup.exe")
        $present = @($setups | Where-Object { Test-Path -LiteralPath $_ })
        $users = @(Get-ChildItem (Join-Path $env:SystemDrive 'Users') -Directory -ErrorAction SilentlyContinue |
                Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'AppData\Local\Microsoft\OneDrive') })
        $perMachine = (Test-Path 'C:\Program Files\Microsoft OneDrive') -or (Test-Path 'C:\Program Files (x86)\Microsoft OneDrive')
        if ($present.Count -gt 0 -or $users.Count -gt 0 -or $perMachine) {
            return @{ Status = 'Pending'; Detail = 'OneDrive files present'; Prior = $null }
        }
        return @{ Status = 'Applied'; Detail = ''; Prior = $null }
    }

    Apply = {
        param($Action, $Test)
        Get-Process -Name 'OneDrive*' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        $setupPaths = @("$env:SystemRoot\System32\OneDriveSetup.exe", "$env:SystemRoot\SysWOW64\OneDriveSetup.exe")
        $perUser = @()
        foreach ($t in @(Get-UserTargets)) {
            if ($t.Kind -ne 'user') { continue }
            $sub = ($t.Root -replace '^HKU\\', '')
            $rk = [Microsoft.Win32.Registry]::Users.OpenSubKey("$sub\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe")
            if ($rk) {
                $us = $rk.GetValue('UninstallString'); $rk.Close()
                if ($us) {
                    # UninstallString looks like: "C:\...\OneDriveSetup.exe" /uninstall
                    $exe = ($us -replace '^\s*"([^"]+)".*$', '$1')
                    if (Test-Path -LiteralPath $exe) { $perUser += $exe }
                }
            }
        }
        foreach ($exe in (@($perUser) + $setupPaths | Select-Object -Unique)) {
            if (Test-Path -LiteralPath $exe) {
                Write-Log INFO "Uninstalling OneDrive: $exe"
                Start-Process -FilePath $exe -ArgumentList '/uninstall' -Wait -NoNewWindow -ErrorAction SilentlyContinue
            }
        }
        foreach ($u in @(Get-ChildItem (Join-Path $env:SystemDrive 'Users') -Directory -ErrorAction SilentlyContinue)) {
            $app = Join-Path $u.FullName 'AppData\Local\Microsoft\OneDrive'
            if (Test-Path -LiteralPath $app) { Remove-Item -LiteralPath $app -Recurse -Force -ErrorAction SilentlyContinue }
            $lnk = Join-Path $u.FullName 'AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk'
            if (Test-Path -LiteralPath $lnk) { Remove-Item -LiteralPath $lnk -Force -ErrorAction SilentlyContinue }
        }
    }

    Undo = {
        param($Action, $Prior)
        Write-Log WARN 'OneDrive removal cannot be undone by the tool. Reinstall: winget install Microsoft.OneDrive'
    }
}
