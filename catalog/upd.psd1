# Windows Update tweaks (group 1).
@{
    Tweaks = @(
        @{
            Id = 'upd.pause-2038'
            Name = 'Pause updates to 2038-01-19 via UX\Settings pause values, raise FlightSettingsMaxPauseDays'
            Risk = 'med'
            Phase = 60
            Source = 'RV,RT,OD,WH'
            Note = 'Windows can reset these values after feature updates (drift). Conflicts with upd.policy-* alternatives.'
            Actions = @(
                @{ Type = 'Script'; Script = 'UpdatePause' }
            )
        }
        @{
            Id = 'upd.drivers-wu-off'
            Name = 'Exclude driver updates from Windows Update (ExcludeWUDriversInQualityUpdate, DriverSearching)'
            Risk = 'med'
            Phase = 10
            Source = 'RV,RT,WH'
            Note = 'Policy-key writes under WindowsUpdate are wiped by a revert-style key delete; apply after it.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\DriverSearching'; Name = 'DontSearchWindowsUpdate'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\DriverSearching'; Name = 'DriverUpdateWizardWuSearchEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\DriverSearching'; Name = 'DontPromptForWindowsUpdate'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching'; Name = 'DontPromptForWindowsUpdate'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching'; Name = 'SearchOrderConfig'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DriverSearching'; Name = 'DontSearchWindowsUpdate'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'ExcludeWUDriversInQualityUpdate'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'; Name = 'ExcludeWUDriversInQualityUpdate'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata'; Name = 'PreventDeviceMetadataFromNetwork'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata'; Name = 'PreventDeviceMetadataFromNetwork'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'upd.notification-level'
            Name = 'Windows Update notification level 2 (SetUpdateNotificationLevel)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,WH'
            Note = 'Uses the documented value name SetUpdateNotificationLevel. Wiped if the WindowsUpdate policy key is deleted later.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate'; Name = 'SetUpdateNotificationLevel'; Kind = 'DWord'; Value = 2 }
            )
        }
        @{
            Id = 'upd.hide-upgrade-mct'
            Name = 'Hide upgrade-available notice and Media Creation Tool link, restart notifications off'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\Setup\UpgradeNotification'; Name = 'UpgradeAvailable'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'; Name = 'HideMCTLink'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'; Name = 'RestartNotificationsAllowed2'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'upd.delivery-optimization-off'
            Name = 'Delivery Optimization peer-to-peer off (DODownloadMode=0, HTTP only)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WU,WH'
            Note = 'RV/OD/WU value 0 (HTTP only); WH uses 99. DoSvc is handled in the svc group.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization'; Name = 'DODownloadMode'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'upd.insider-off'
            Name = 'Insider/preview builds off (AllowBuildPreview=0, EnableConfigFlighting=0)'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Note = 'Hiding the Insider Settings page (shared SettingsPageVisibility value) is left to the misc hide-pages items.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds'; Name = 'AllowBuildPreview'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'AllowBuildPreview'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds'; Name = 'EnableConfigFlighting'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'upd.store-autodownload-off'
            Name = 'Microsoft Store auto-download of app updates off, OS upgrade offer off'
            Risk = 'low'
            Phase = 10
            Source = 'RV,WH'
            Note = 'WH recommends the opposite (keep Store updates on).'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\WindowsStore'; Name = 'AutoDownload'; Kind = 'DWord'; Value = 4 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\WindowsStore'; Name = 'DisableOSUpgrade'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'upd.wmp-autoupdate-off'
            Name = 'Windows Media Player auto-update off'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\WindowsMediaPlayer'; Name = 'DisableAutoUpdate'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'upd.register-au-off'
            Name = 'Microsoft Update pending service RegisterWithAU=0'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending\7971f918-a847-4430-9279-4a52d1efe18d'; Name = 'RegisterWithAU'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'upd.hw-requirements-bypass'
            Name = 'Allow upgrades on unsupported TPM/CPU, hide unsupported-hardware notice'
            Risk = 'low'
            Phase = 10
            Source = 'RV,WU'
            Note = 'LabConfig Bypass* values are install-time only and not written.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\Setup\MoSetup'; Name = 'AllowUpgradesWithUnsupportedTPMOrCPU'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\UnsupportedHardwareNotificationCache'; Name = 'SV1'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\UnsupportedHardwareNotificationCache'; Name = 'SV2'; Kind = 'DWord'; Value = 0 }
            )
        }
    )
}
