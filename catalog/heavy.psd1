# Heavy items implemented as Script actions (scripts in engine\scripts\). Each is risky enough to be reviewed on its own.
@{
    Tweaks = @(
        @{
            Id = 'sec.defender-disable'; Name = 'Disable Microsoft Defender (policy + core keys + MDCoreSvc; reversible, files stay)'
            Risk = 'high'; Phase = 45; Reboot = $true; Source = 'RV,RT'; Requires = @('admin', 'tamper-off')
            Note = 'Tamper Protection must be off first; an interactive apply opens Windows Security and waits for you to turn it off. Jan-2026 updates strip the policy value: re-apply after updates. No CBS package removal.'
            Actions = @( @{ Type = 'Script'; Script = 'DefenderDisable' } )
        }
        @{
            Id = 'edge.remove-edge'; Name = 'Remove Microsoft Edge (Chromium); keep WebView2 and Edge Update'
            Risk = 'high'; Phase = 40; Source = 'RV,WU,WH'; Requires = @('admin')
            Note = 'Needs a non-EEA region (checked). Windows Update can bring Edge back: apply -DriftOnly after updates.'
            Actions = @(
                @{ Type = 'Script'; Script = 'EdgeRemoval' }
                @{ Type = 'Appx'; Name = 'Microsoft.MicrosoftEdge' }
                @{ Type = 'Appx'; Name = 'Microsoft.MicrosoftEdgeDevToolsClient' }
                @{ Type = 'Appx'; Name = 'Microsoft.Edge.GameAssist' }
            )
        }
        @{
            Id = 'edge.remove-onedrive'; Name = 'Uninstall OneDrive (user files are not touched)'
            Risk = 'med'; Phase = 40; Source = 'RV,RT,WU,WH'; Requires = @('admin')
            Note = 'Does not delete %USERPROFILE%\OneDrive.'
            Actions = @(
                @{ Type = 'Script'; Script = 'OneDriveRemoval' }
                @{ Type = 'Appx'; Name = 'OneDrive' }
                @{ Type = 'Appx'; Name = 'microsoft.microsoftskydrive' }
                @{ Type = 'File'; Op = 'Delete'; Path = '%SystemDrive%\OneDriveTemp' }
                @{ Type = 'File'; Op = 'Delete'; Path = '%ProgramData%\Microsoft OneDrive' }
                @{ Type = 'Registry'; Path = 'HKCR\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}'; Name = 'System.IsPinnedToNameSpaceTree'; Kind = 'DWord'; Value = 0; RequireKey = $true }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run'; Name = 'OneDrive'; Op = 'DeleteValue' }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Run'; Name = 'OneDriveSetup'; Op = 'DeleteValue' }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe'; Op = 'DeleteKey' }
            )
        }
        @{
            Id = 'start.remove-pinned-items'; Name = 'Replace default Start pins with Store, Settings, Notepad, Paint, Explorer, Calculator'
            Risk = 'med'; Phase = 50; RestartExplorer = $true; Source = 'RV'; Requires = @('admin')
            Note = 'ConfigureStartPins support on Pro 24H2 is unverified; DefaultLayouts.xml from ReviOS is not copied.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start'; Name = 'ConfigureStartPins'; Kind = 'String'; TI = $true
                    Value = '{"pinnedList":[{"packagedAppId":"Microsoft.WindowsStore_8wekyb3d8bbwe!App"},{"packagedAppId":"windows.immersivecontrolpanel_cw5n1h2txyewy!microsoft.windows.immersivecontrolpanel"},{"packagedAppId":"Microsoft.WindowsNotepad_8wekyb3d8bbwe!App"},{"packagedAppId":"Microsoft.Paint_8wekyb3d8bbwe!App"},{"desktopAppLink":"%APPDATA%\\Microsoft\\Windows\\Start Menu\\Programs\\File Explorer.lnk"},{"packagedAppId":"Microsoft.WindowsCalculator_8wekyb3d8bbwe!App"}]}' }
                @{ Type = 'Script'; Script = 'StartPins' }
            )
        }
    )
}
