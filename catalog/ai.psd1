# Group 2 catalog: ai. Generated from docs/tweaks/group2.mech.md.
@{
    Tweaks = @(
        @{
            Id = 'ai.remove-copilot-appx'
            Name = 'Remove Copilot app (Microsoft.Copilot, Windows.Ai.Copilot.Provider, MicrosoftWindows.Client.CoPilot)'
            Risk = 'low'
            Phase = 30
            Source = 'RV,RT,WU,WH,OD'
            Actions = @(
                @{ Type = 'Appx'; Name = 'Microsoft.Copilot' }
                @{ Type = 'Appx'; Name = 'Microsoft.Windows.Ai.Copilot.Provider' }
                @{ Type = 'Appx'; Name = 'MicrosoftWindows.Client.CoPilot' }
            )
        }
        @{
            Id = 'ai.disable-copilot-policy'
            Name = 'TurnOffWindowsCopilot=1 (HKLM+HKCU), hide button, block shell extension'
            Risk = 'low'
            Phase = 10
            Source = 'OD,WH'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\Software\Policies\Microsoft\Windows\WindowsCopilot'; Name = 'TurnOffWindowsCopilot'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\WindowsCopilot'; Name = 'TurnOffWindowsCopilot'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'ShowCopilotButton'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked'; Name = '{CB3B0003-8088-4EDE-8769-8B354AB2FF8C}'; Kind = 'String'; Value = '' }
            )
        }
        @{
            Id = 'ai.disable-recall-policy'
            Name = 'Recall policies: DisableAIDataAnalysis, AllowRecallEnablement=0, TurnOffSavingSnapshots'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WH'
            Builds = @{ Min = 26100 }
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\Software\Policies\Microsoft\Windows\WindowsAI'; Name = 'DisableAIDataAnalysis'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Policies\Microsoft\Windows\WindowsAI'; Name = 'AllowRecallEnablement'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Policies\Microsoft\Windows\WindowsAI'; Name = 'TurnOffSavingSnapshots'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\WindowsAI'; Name = 'DisableAIDataAnalysis'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\WindowsAI'; Name = 'TurnOffSavingSnapshots'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'ai.recall-feature-remove'
            Name = 'Disable-WindowsOptionalFeature Recall (-Remove)'
            Risk = 'low'
            Phase = 30
            Source = 'OD,WU'
            Note = 'N/A where the Recall feature does not exist.'
            Reboot = $true
            Actions = @(
                @{ Type = 'Feature'; Name = 'Recall'; State = 'Disabled'; Remove = $true }
            )
        }
        @{
            Id = 'ai.disable-click-to-do'
            Name = 'DisableClickToDo=1 (HKLM+HKCU)'
            Risk = 'low'
            Phase = 10
            Source = 'OD,WH'
            Builds = @{ Min = 26100 }
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\Software\Policies\Microsoft\Windows\WindowsAI'; Name = 'DisableClickToDo'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Policies\Microsoft\Windows\WindowsAI'; Name = 'DisableClickToDo'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'ai.bing-copilot-ifeo-block'
            Name = 'IFEO taskkill for BingChatInstaller, BGAUpsell, BCILauncher'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\BingChatInstaller.exe'; Name = 'Debugger'; Kind = 'String'; Value = '%windir%\System32\taskkill.exe'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\BGAUpsell.exe'; Name = 'Debugger'; Kind = 'String'; Value = '%windir%\System32\taskkill.exe'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\BCILauncher.exe'; Name = 'Debugger'; Kind = 'String'; Value = '%windir%\System32\taskkill.exe'; TI = $true }
            )
        }
    )
}
