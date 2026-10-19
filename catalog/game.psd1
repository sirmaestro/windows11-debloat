@{
    Tweaks = @(
        @{
            Id = 'game.gamedvr-off'; Name = 'Game DVR/background capture off (GameDVR_Enabled=0, AppCaptureEnabled=0, AllowGameDVR=0)'
            Risk = 'low'; Phase = 10; Source = 'RV,WU,WH,OD'
            Note = 'ReviOS applies AppCaptureEnabled=0 only if Xbox is removed (else Start Recording greyed, #74).'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\System\GameConfigStore'; Name = 'GameDVR_Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\System\GameConfigStore'; Name = 'GameDVR_HistoricalCaptureEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'AppCaptureEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR'; Name = 'HistoricalCaptureEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR'; Name = 'AllowGameDVR'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'game.gamebar-off'; Name = 'Xbox Game Bar off (GameBarEnabled=0, ShowStartupPanel=0, UseNexusForGameBarEnabled=0)'
            Risk = 'low'; Phase = 10; Source = 'OD,WH'
            Note = 'Breaks Win+G overlay and controller Xbox-button launch.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\System\GameConfigStore'; Name = 'GameBarEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\GameBar'; Name = 'ShowStartupPanel'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\GameBar'; Name = 'UseNexusForGameBarEnabled'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'game.game-mode'; Name = 'Game Mode on (AllowAutoGameMode=1, AutoGameModeEnabled=1)'
            Risk = 'low'; Phase = 10; Source = 'WU,WH,OD'
            Note = 'Windows default is on.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\GameBar'; Name = 'AllowAutoGameMode'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\GameBar'; Name = 'AutoGameModeEnabled'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'game.mouse-accel-off'; Name = 'Mouse acceleration off (MouseSpeed/MouseThreshold1/MouseThreshold2=0)'
            Risk = 'low'; Phase = 10; Source = 'RV,WU,WH,OD'
            Note = 'Defaults are 1 / 6 / 10.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Mouse'; Name = 'MouseSpeed'; Kind = 'String'; Value = '0' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Mouse'; Name = 'MouseThreshold1'; Kind = 'String'; Value = '0' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Mouse'; Name = 'MouseThreshold2'; Kind = 'String'; Value = '0' }
            )
        }
        @{
            Id = 'game.vbs-hvci-off'; Name = 'Disable VBS / Memory Integrity (HVCI) for gaming performance'
            Risk = 'high'; Phase = 20; Source = 'RV,OD'; Reboot = $true
            Note = 'Same as sec.vbs-hvci-off (idempotent copy). Security trade-off; mechanism from the OD/revitool inventory.'
            Actions = @(
                @{ Type = 'Bcdedit'; Name = 'vsmlaunchtype'; Value = 'Off' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name = 'EnableVirtualizationBasedSecurity'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name = 'LsaCfgFlags'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name = 'HVCIMATRequired'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard'; Name = 'EnableVirtualizationBasedSecurity'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard'; Name = 'Mandatory'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard'; Name = 'HVCIMATRequired'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'; Name = 'Enabled'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'; Name = 'WasEnabledBy'; Op = 'DeleteValue'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'; Name = 'ChangedInBootCycle'; Op = 'DeleteValue'; TI = $true }
            )
        }
        @{
            Id = 'game.gaming-copilot-block'; Name = 'Block Gaming Copilot companion host (GamingCompanionHostOptions ActivationType)'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Note = 'Also relevant to the AI group. Revert deletes the values.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.Xbox.GamingAI.Companion.Host.GamingCompanionHostOptions'; Name = 'ActivationType'; Kind = 'DWord'; Value = 4294967295; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.Xbox.GamingAI.Companion.Host.GamingCompanionHostOptions'; Name = 'Server'; Kind = 'String'; Value = ''; TI = $true }
            )
        }
        @{
            Id = 'game.boot-timer-defaults'; Name = 'bcdedit: delete useplatformclock and disabledynamictick (leave timer defaults)'
            Risk = 'low'; Phase = 20; Source = 'RV'; Reboot = $true
            Note = 'ReviOS does not set useplatformtick/disabledynamictick yes (breaks ROG Ally sleep, #167).'
            Actions = @(
                @{ Type = 'Bcdedit'; Name = 'useplatformclock'; Op = 'DeleteValue' }
                @{ Type = 'Bcdedit'; Name = 'disabledynamictick'; Op = 'DeleteValue' }
            )
        }
        @{
            Id = 'game.vulnerable-driver-blocklist'; Name = 'Keep Vulnerable Driver Blocklist enabled; Spectre/Meltdown mitigation overrides left default'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Note = 'Setting 0 breaks THE FINALS anti-cheat. Process-mitigation policy keys (ambiguous key/value in the inventory) are not touched.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\CI\Config'; Name = 'VulnerableDriverBlocklistEnable'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'; Name = 'FeatureSettings'; Op = 'DeleteValue' }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'; Name = 'FeatureSettingsOverride'; Op = 'DeleteValue' }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'; Name = 'FeatureSettingsOverrideMask'; Op = 'DeleteValue' }
            )
        }
    )
}
