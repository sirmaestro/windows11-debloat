# Group 2 catalog: misc-features. Generated from docs/tweaks/group2.mech.md.
@{
    Tweaks = @(
        @{
            Id = 'misc.hide-settings-pages'
            Name = 'Hide Settings pages: cortana, privacy-feedback, windowsinsider, home (+ crossdevice, aicomponents)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,RT,OD'
            Note = 'Merged page list incl. crossdevice and aicomponents (per TWEAKS.md title).'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'SettingsPageVisibility'; Kind = 'String'; Value = 'hide:cortana;privacy-feedback;windowsinsider;home;crossdevice;aicomponents;' }
            )
        }
        @{
            Id = 'misc.hide-insider-page-wu-tray'
            Name = 'HideInsiderPage=1 and Windows Update tray icon hidden'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsSelfHost\UI\Visibility'; Name = 'HideInsiderPage'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings'; Name = 'TrayIconVisibility'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'misc.enable-sudo'
            Name = 'Enable sudo for Windows (Sudo\Enabled=3, inline)'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Note = 'Inline mode; 24H2+.'
            Builds = @{ Min = 26100 }
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Sudo'; Name = 'Enabled'; Kind = 'DWord'; Value = 3 }
            )
        }
        @{
            Id = 'misc.typing-suggestions-off'
            Name = 'Autocorrect/spellcheck/text prediction/Input Insights off (TabletTip, Input\Settings)'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7'; Name = 'EnableAutocorrection'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7'; Name = 'EnableSpellchecking'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7'; Name = 'EnableTextPrediction'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7'; Name = 'EnablePredictionSpaceInsertion'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\TabletTip\1.7'; Name = 'EnableDoubleTapSpace'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\TabletTip\1.7'; Name = 'EnableAutocorrection'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\TabletTip\1.7'; Name = 'EnableSpellchecking'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\TabletTip\1.7'; Name = 'EnableTextPrediction'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\TabletTip\1.7'; Name = 'EnablePredictionSpaceInsertion'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\TabletTip\1.7'; Name = 'EnableDoubleTapSpace'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Input\Settings'; Name = 'InsightsEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Input\Settings'; Name = 'EnableHwkbTextPrediction'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Input\Settings'; Name = 'EnableHwkbAutocorrection'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Input\Settings'; Name = 'MultilingualEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Microsoft\Input\Settings'; Name = 'InsightsEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Microsoft\Input\Settings'; Name = 'EnableHwkbTextPrediction'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Microsoft\Input\Settings'; Name = 'EnableHwkbAutocorrection'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Microsoft\Input\Settings'; Name = 'MultilingualEnabled'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'misc.inking-workspace'
            Name = 'Ink Workspace suggested apps off'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace'; Name = 'AllowWindowsInkWorkspace'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\WindowsInkWorkspace'; Name = 'AllowSuggestedAppsInWindowsInkWorkspace'; Kind = 'DWord'; Value = 0 }
            )
        }
    )
}
