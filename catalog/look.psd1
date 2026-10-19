@{
    Tweaks = @(
        @{
            Id = 'look.dark-mode'; Name = 'Dark mode for system and apps'; Risk = 'low'; Phase = 50; Source = 'RV,WU,OD,WH'; RestartExplorer = $true
            Note = 'Registry keys only (no theme file)'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name = 'AppsUseLightTheme'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name = 'SystemUsesLightTheme'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'look.transparency-off'; Name = 'Disable transparency effects'; Risk = 'low'; Phase = 50; Source = 'RV,WU,OD,WH'; RestartExplorer = $true
            Note = 'EnableTransparency=0 (MinAnimate lives in look.animations-off)'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize'; Name = 'EnableTransparency'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'look.jpeg-quality-100'; Name = 'Wallpaper JPEG import quality 100'; Risk = 'low'; Phase = 10; Source = 'RV,WH'
            Note = 'JPEGImportQuality=100'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Desktop'; Name = 'JPEGImportQuality'; Kind = 'DWord'; Value = 100 }
            )
        }
        @{
            Id = 'look.beeps-off'; Name = 'Turn off system beeps'; Risk = 'low'; Phase = 10; Source = 'RV'
            Note = 'Sound\Beep=no; do not disable the Beep service'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Sound'; Name = 'Beep'; Kind = 'String'; Value = 'no' }
            )
        }
        @{
            Id = 'look.startup-sound-off'; Name = 'Disable startup sound and first-logon animation'; Risk = 'low'; Phase = 10; Source = 'RV,WH'
            Note = 'RV Policies\System values + WH LogonUI BootAnimation/EditionOverrides values'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'EnableFirstLogonAnimation'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'DisableStartupSound'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation'; Name = 'DisableStartupSound'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Microsoft\Windows\CurrentVersion\EditionOverrides'; Name = 'UserSetting_DisableStartupSound'; Kind = 'DWord'; Value = 1; TI = $true }
            )
        }
        @{
            Id = 'look.audio-ducking-off'; Name = 'Communications ducking = Do nothing'; Risk = 'low'; Phase = 10; Source = 'RV,WH'
            Note = 'UserDuckingPreference=3; Narrator DuckAudio=0'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Multimedia\Audio'; Name = 'UserDuckingPreference'; Kind = 'DWord'; Value = 3 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Narrator\NoRoam'; Name = 'DuckAudio'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'look.menu-responsiveness'; Name = 'MenuShowDelay=0, ActiveWndTrkTimeout=10, Explorer startup delay 0'; Risk = 'low'; Phase = 10; Source = 'RV,WU,OD,WH'
            Note = 'MouseHoverTime deliberately not lowered'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Desktop'; Name = 'MenuShowDelay'; Kind = 'String'; Value = '0' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Desktop'; Name = 'ActiveWndTrkTimeout'; Kind = 'DWord'; Value = 10 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize'; Name = 'StartupDelayInMSec'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'look.mouse-accel-off'; Name = 'Disable Enhance Pointer Precision'; Risk = 'low'; Phase = 10; Source = 'RV,WU,OD,WH'
            Note = 'MouseSpeed/Threshold1/Threshold2 = 0'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Mouse'; Name = 'MouseSpeed'; Kind = 'String'; Value = '0' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Mouse'; Name = 'MouseThreshold1'; Kind = 'String'; Value = '0' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Mouse'; Name = 'MouseThreshold2'; Kind = 'String'; Value = '0' }
            )
        }
        @{
            Id = 'look.sticky-keys-prompts-off'; Name = 'Disable Sticky/Filter/Toggle Keys shortcut popups'; Risk = 'low'; Phase = 10; Source = 'WU,OD,WH'
            Note = 'OD/WH flag values (hotkey bit cleared); not the accessibility-reset approach'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Accessibility\StickyKeys'; Name = 'Flags'; Kind = 'String'; Value = '26' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Accessibility\Keyboard Response'; Name = 'Flags'; Kind = 'String'; Value = '2' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Accessibility\ToggleKeys'; Name = 'Flags'; Kind = 'String'; Value = '34' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Accessibility\MouseKeys'; Name = 'Flags'; Kind = 'String'; Value = '130' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Accessibility\HighContrast'; Name = 'Flags'; Kind = 'String'; Value = '4194' }
            )
        }
        @{
            Id = 'look.spotlight-lockscreen-off'; Name = 'Disable Spotlight, lock-screen tips, third-party suggestions'; Risk = 'low'; Phase = 10; Source = 'RV,WH'
            Note = 'ContentDeliveryManager + CloudContent policies; DisableWindowsConsumerFeatures intentionally not set'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'ContentDeliveryAllowed'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContentEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-310093Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338389Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-314559Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280815Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-314563Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-202914Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338387Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280810Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280811Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-353698Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338388Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SoftLandingEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SilentInstalledAppsEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'PreInstalledAppsEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'PreInstalledAppsEverEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'OemPreInstalledAppsEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'FeatureManagementEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'RemediationRequired'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'RotatingLockScreenEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'RotatingLockScreenOverlayEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SystemPaneSuggestionsEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions'; Op = 'DeleteKey' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\SuggestedApps'; Op = 'DeleteKey' }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableSoftLanding'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableTailoredExperiencesWithDiagnosticData'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableCloudOptimizedContent'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'ConfigureWindowsSpotlight'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'IncludeEnterpriseSpotlight'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableThirdPartySuggestions'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableTailoredExperiencesWithDiagnosticData'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsSpotlightFeatures'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsSpotlightWindowsWelcomeExperience'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsSpotlightOnActionCenter'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsSpotlightOnSettings'; Kind = 'DWord'; Value = 1 }
            )
        }
    )
}

