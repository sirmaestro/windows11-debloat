# Script action: remove Microsoft Edge (Chromium) from a live system. WebView2 and Edge Update are left alone.
# Technique ported from the ReviOS playbook (EDGE.ps1) / Winhance / winutil:
#   1. remove the 'NoRemove' flag, set EdgeUpdateDev\AllowUninstall=1
#   2. create a stub SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe (activates "BrowserReplacement"
#      so Edge's own uninstaller is permitted) - REGION MUST BE NON-EEA (New Zealand is fine)
#   3. run Edge's setup.exe --uninstall --force-uninstall --delete-profile with a spoofed allowed parent process
#      (a copy of cmd.exe named sihost.exe in ImmersiveControlPanel), with %windir% temporarily empty
#   4. remove shortcuts
# Edge's Appx packages (Microsoft.MicrosoftEdge, DevToolsClient, Edge.GameAssist) are separate Appx actions in the catalog entry.
# Windows Update can reinstall Edge: re-apply via 'apply -DriftOnly' (edge.block-edge-reinstall policies reduce this).
# Not reversible by the tool (reinstall from microsoft.com or: winget install Microsoft.Edge).
# NOTE: untested outside the reference projects; test in a VM first.

return @{
    Test = {
        param($Action)
        $edgeExe = Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application\msedge.exe'
        $client = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\Clients\{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}'
        $installed = (Test-Path -LiteralPath $edgeExe) -or (Test-Path -LiteralPath $client)
        if ($installed) { return @{ Status = 'Pending'; Detail = 'Microsoft Edge is installed'; Prior = $null } }
        return @{ Status = 'Applied'; Detail = ''; Prior = $null }
    }

    Apply = {
        param($Action, $Test)
        $eea = @('AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR', 'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL', 'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'IS', 'LI', 'NO')
        $geo = (Get-ItemProperty 'HKCU:\Control Panel\International\Geo' -ErrorAction SilentlyContinue).Name
        if ($geo -and $eea -contains $geo) { throw "Region '$geo' is in the EEA: Edge's uninstaller refuses to run. Change Settings > Time & language > Region to a non-EEA country, then retry." }

        # WebView2 (msedgewebview2) is deliberately NOT stopped or removed.
        foreach ($n in @('msedge', 'MicrosoftEdgeUpdate')) {
            Get-Process -Name $n -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
        }
        Get-Process -Name 'MicrosoftEdge*' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

        $uninstKey = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge'
        Remove-ItemProperty -Path $uninstKey -Name 'NoRemove' -ErrorAction SilentlyContinue
        [Microsoft.Win32.Registry]::SetValue('HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev', 'AllowUninstall', 1, [Microsoft.Win32.RegistryValueKind]::DWord)

        $clientState = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate\ClientState\{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}'
        if (-not (Test-Path -LiteralPath $clientState)) { throw "Edge ClientState key not found ($clientState); cannot uninstall." }
        Remove-ItemProperty -Path $clientState -Name 'experiment_control_labels' -ErrorAction SilentlyContinue
        $cs = Get-ItemProperty -Path $clientState
        $setup = $cs.UninstallString; $uargs = $cs.UninstallArguments
        if ([string]::IsNullOrEmpty($setup) -or [string]::IsNullOrEmpty($uargs)) { throw 'Edge uninstall command not found in ClientState.' }
        if (-not (Test-Path -LiteralPath $setup)) { throw "Edge setup.exe not found: $setup" }
        $uargs += ' --force-uninstall --delete-profile'

        # stub MicrosoftEdge.exe (BrowserReplacement); SystemApps may need TrustedInstaller
        $stubDir = Join-Path $env:SystemRoot 'SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe'
        $stubFile = Join-Path $stubDir 'MicrosoftEdge.exe'
        $makeStub = {
            [IO.Directory]::CreateDirectory($stubDir) | Out-Null
            if (-not (Test-Path -LiteralPath $stubFile)) { [IO.File]::Create($stubFile).Close() }
        }
        try { & $makeStub } catch [System.UnauthorizedAccessException] { Invoke-AsTrustedInstaller $makeStub }

        # spoofed allowed parent process: dllhost / msiexec / sihost / SystemSettings
        $spoofDir = Join-Path $env:SystemRoot 'ImmersiveControlPanel'
        $spoof = Join-Path $spoofDir 'sihost.exe'
        $cmdExe = Join-Path $env:SystemRoot 'System32\cmd.exe'
        $copySpoof = { [IO.File]::Copy($cmdExe, $spoof, $true) }
        $oldWindir = $env:windir
        try {
            try { & $copySpoof } catch [System.UnauthorizedAccessException] { Invoke-AsTrustedInstaller $copySpoof }
            $env:windir = ''
            $p = Start-Process -FilePath $spoof -ArgumentList ('/c "' + $setup + '" ' + $uargs) -Wait -NoNewWindow -PassThru
            Write-Log INFO "Edge uninstaller exit code: $($p.ExitCode)"
        }
        finally {
            $env:windir = $oldWindir
            Remove-Item -LiteralPath $spoof -Force -ErrorAction SilentlyContinue
        }

        foreach ($d in @("$env:ProgramData\Microsoft\Windows\Start Menu\Programs", $env:PUBLIC + '\Desktop')) {
            $lnk = Join-Path $d 'Microsoft Edge.lnk'
            if (Test-Path -LiteralPath $lnk) { Remove-Item -LiteralPath $lnk -Force -ErrorAction SilentlyContinue }
        }
        foreach ($u in @(Get-ChildItem (Join-Path $env:SystemDrive 'Users') -Directory -ErrorAction SilentlyContinue)) {
            $lnk = Join-Path $u.FullName 'Desktop\Microsoft Edge.lnk'
            if (Test-Path -LiteralPath $lnk) { Remove-Item -LiteralPath $lnk -Force -ErrorAction SilentlyContinue }
        }
    }

    Undo = {
        param($Action, $Prior)
        Write-Log WARN 'Edge removal cannot be undone by the tool. Reinstall: winget install Microsoft.Edge'
    }
}
