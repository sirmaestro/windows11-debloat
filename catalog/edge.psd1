# Group 2 catalog: edge. Generated from docs/tweaks/group2.mech.md.
@{
    Tweaks = @(
        @{
            Id = 'edge.block-edge-reinstall'
            Name = 'EdgeUpdate policies: InstallDefault=0, Install{Edge}=0, Install{WebView2}=1, DoNotUpdateToEdgeWithChromium=1 + Edge appx deprovision'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Note = 'WebView2 stays installable.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate'; Name = 'InstallDefault'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate'; Name = 'Install{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate'; Name = 'Install{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\EdgeUpdate'; Name = 'DoNotUpdateToEdgeWithChromium'; Kind = 'DWord'; Value = 1; TI = $true }
            )
        }
        @{
            Id = 'edge.keep-webview2'
            Name = 'Guard: never remove msedgewebview2/EdgeWebView or EdgeUpdate ClientState'
            Risk = 'low'
            Phase = 10
            Source = 'RV,WH'
            Note = 'Guard: keeps WebView2 installable/updatable; no deletion logic.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate'; Name = 'Install{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'edge.edgeupdate-manual'
            Name = 'edgeupdate, edgeupdatem, MicrosoftEdgeElevationService startup = Manual (not Disabled)'
            Risk = 'low'
            Phase = 20
            Source = 'RV,OD'
            Note = 'Manual, not Disabled: Disabled breaks WebView2 install.'
            Actions = @(
                @{ Type = 'Service'; Name = 'edgeupdate'; Start = 'Manual' }
                @{ Type = 'Service'; Name = 'edgeupdatem'; Start = 'Manual' }
                @{ Type = 'Service'; Name = 'MicrosoftEdgeElevationService'; Start = 'Manual' }
            )
        }
        @{
            Id = 'edge.no-desktop-shortcut'
            Name = 'CreateDesktopShortcutDefault=0 and delete Public Edge shortcut'
            Risk = 'low'
            Phase = 10
            Source = 'WU'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate'; Name = 'CreateDesktopShortcutDefault'; Kind = 'DWord'; Value = 0 }
                
            )
        }
        @{
            Id = 'edge.remove-teams'
            Name = 'Remove Teams (MSTeams, MicrosoftTeams, Flipgrid) and Teams Meeting Add-in MSI'
            Risk = 'low'
            Phase = 30
            Source = 'RV,WU,WH,OD'
            Note = 'Kills Teams processes first; removes Teams Meeting Add-in MSI.'
            Actions = @(
                @{ Type = 'Exec'; Test = '-not (Get-Process -Name Teams, ms-teams, ms-teamsupdate, msteams -ErrorAction SilentlyContinue)'; Apply = 'Get-Process -Name Teams, ms-teams, ms-teamsupdate, msteams -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue' }
                @{ Type = 'Appx'; Name = 'MicrosoftTeams' }
                @{ Type = 'Appx'; Name = 'MSTeams' }
                @{ Type = 'Appx'; Name = 'Flipgrid' }
                @{ Type = 'Exec'; Test = '$c = "{A7AB73A3-CB10-4AA5-9D38-6AEFFBDE4C91}"; -not ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$c") -or (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$c"))'; Apply = '$c = "{A7AB73A3-CB10-4AA5-9D38-6AEFFBDE4C91}"; Start-Process -FilePath msiexec.exe -ArgumentList ("/X" + $c + " /qn /norestart") -Wait' }
            )
        }
        @{
            Id = 'edge.block-teams-autoinstall'
            Name = 'ConfigureChatAutoInstall=0'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Communications'; Name = 'ConfigureChatAutoInstall'; Kind = 'DWord'; Value = 0 }
            )
        }
    )
}
