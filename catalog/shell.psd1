@{
    Tweaks = @(
        @{
            Id = 'shell.show-file-extensions'; Name = 'Show file extensions'; Risk = 'low'; Phase = 50; Source = 'RV,WU,OD,WH'; RestartExplorer = $true
            Note = 'HideFileExt=0'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'HideFileExt'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'shell.show-hidden-files'; Name = 'Show hidden files, folders and drives'; Risk = 'low'; Phase = 50; Source = 'WU,OD,WH'; RestartExplorer = $true
            Note = 'Hidden=1'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Hidden'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'shell.launch-to-this-pc'; Name = 'Open File Explorer to This PC'; Risk = 'low'; Phase = 50; Source = 'RV,WU,OD,WH'; RestartExplorer = $true
            Note = 'LaunchTo=1'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'LaunchTo'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'shell.hide-home-gallery'; Name = 'Remove Home and Gallery from navigation pane'; Risk = 'low'; Phase = 50; Source = 'WU,OD,WH'; RestartExplorer = $true
            Note = 'HKCU IsPinnedToNameSpaceTree=0 only (WH HKLM NonEnum/HiddenByDefault not applied); pair with launch-to-this-pc'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}'; Name = 'System.IsPinnedToNameSpaceTree'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}'; Name = 'System.IsPinnedToNameSpaceTree'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'shell.recent-files-off'; Name = 'Stop Quick Access recent files, recommendations, cloud files'; Risk = 'low'; Phase = 50; Source = 'WH'; RestartExplorer = $true
            Note = 'ShowRecent, ShowRecommendations, ShowCloudFilesInQuickAccess = 0'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer'; Name = 'ShowRecent'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer'; Name = 'ShowRecommendations'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer'; Name = 'ShowCloudFilesInQuickAccess'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'shell.frequent-folders-off'; Name = 'Stop Quick Access frequent folders'; Risk = 'low'; Phase = 50; Source = 'WH'; RestartExplorer = $true
            Note = 'ShowFrequent=0'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer'; Name = 'ShowFrequent'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'shell.this-pc-folders-hide'; Name = 'Hide user folders under This PC'; Risk = 'low'; Phase = 50; Source = 'WH'; RestartExplorer = $true
            Note = 'HiddenByDefault=1 for 6 folders (HKLM + WOW6432Node), N/A if key absent'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{D3162B92-9365-467A-956B-92703ACA08AF}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{D3162B92-9365-467A-956B-92703ACA08AF}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088E3905-0323-4B02-9826-5D99428E115F}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088E3905-0323-4B02-9826-5D99428E115F}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3DFDF296-DBEC-4FB4-81D1-6A3438BCF4DE}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3DFDF296-DBEC-4FB4-81D1-6A3438BCF4DE}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24AD3AD4-A569-4530-98E1-AB02F9417AA8}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24AD3AD4-A569-4530-98E1-AB02F9417AA8}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{F86FA3AB-70D2-4FC7-9C99-FCBF05467F3A}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{F86FA3AB-70D2-4FC7-9C99-FCBF05467F3A}'; Name = 'HiddenByDefault'; Kind = 'DWord'; Value = 1; RequireKey = $true; TI = $true }
            )
        }
        @{
            Id = 'shell.full-path-title'; Name = 'Show full path in Explorer title bar'; Risk = 'low'; Phase = 50; Source = 'RV,WH'; RestartExplorer = $true
            Note = 'CabinetState FullPath=1'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState'; Name = 'FullPath'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'shell.sync-provider-notifications-off'; Name = 'Turn off sync-provider ads in Explorer'; Risk = 'low'; Phase = 50; Source = 'RV,OD,WH'; RestartExplorer = $true
            Note = 'ShowSyncProviderNotifications=0'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ShowSyncProviderNotifications'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'shell.info-tips-off'; Name = 'Disable pop-up descriptions for folder/desktop items'; Risk = 'low'; Phase = 50; Source = 'RV,WH'; RestartExplorer = $true
            Note = 'ShowInfoTip=0'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ShowInfoTip'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'shell.shortcut-suffix-off'; Name = 'Remove " - Shortcut" suffix on new shortcuts'; Risk = 'low'; Phase = 50; Source = 'RV,WH'; RestartExplorer = $true
            Note = 'Explorer\link binary 00000000; revert deletes value'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer'; Name = 'link'; Kind = 'Binary'; Value = '00-00-00-00' }
            )
        }
        @{
            Id = 'shell.hide-spotlight-desktop-icon'; Name = 'Hide Spotlight "Learn about this picture" desktop icon'; Risk = 'low'; Phase = 50; Source = 'RV'; RestartExplorer = $true
            Note = 'HKLM HideDesktopIcons NewStartPanel (24H2)'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel'; Name = '{2cc5ca98-6485-489a-920e-b3e88a6ccce3}'; Kind = 'DWord'; Value = 1; TI = $true }
            )
        }
        @{
            Id = 'shell.tablet-mode-desktop'; Name = 'Always desktop mode, no tablet mode prompts'; Risk = 'low'; Phase = 50; Source = 'RV'; RestartExplorer = $true
            Note = 'SignInMode=1, TabletMode=0, ConvertibleSlateModePromptPreference=2, taskbar tablet values'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell'; Name = 'SignInMode'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell'; Name = 'TabletMode'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\ImmersiveShell'; Name = 'ConvertibleSlateModePromptPreference'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarAppsVisibleInTabletMode'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'TaskbarAutoHideInTabletMode'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'shell.cross-device-resume-block'; Name = 'Block Cross Device Resume host and policy'; Risk = 'low'; Phase = 10; Source = 'RV'
            Note = 'ProcessPath redirect + IsResumeAllowed=0 + PolicyManager DisableCrossDeviceResume=1'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell\ShellUIHosts\CrossDeviceResumeHost'; Name = 'ProcessPath'; Kind = 'ExpandString'; Value = '%SystemRoot%\system32\ShellHost.exe'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\CrossDeviceResume\Configuration'; Name = 'IsResumeAllowed'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\Connectivity\DisableCrossDeviceResume'; Name = 'value'; Kind = 'DWord'; Value = 1; TI = $true }
            )
        }
    )
}

