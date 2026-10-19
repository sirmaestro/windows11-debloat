# Group 2 catalog: feat. Generated from docs/tweaks/group2.mech.md.
@{
    Tweaks = @(
        @{
            Id = 'feat.update-health-tools-removal'
            Name = 'Uninstall Update Health Tools, PC Health Check, Windows Installation Assistant'
            Risk = 'low'
            Phase = 30
            Source = 'RV'
            Note = 'Windows Update may reinstall Update Health Tools.'
            Actions = @(
                @{ Type = 'Exec'; Test = '$c = "{43D501A5-E5E3-46EC-8F33-9E15D2A2CBD5}"; -not ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$c") -or (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$c"))'; Apply = '$c = "{43D501A5-E5E3-46EC-8F33-9E15D2A2CBD5}"; Start-Process -FilePath msiexec.exe -ArgumentList ("/X" + $c + " /qn /norestart") -Wait' }
                @{ Type = 'Exec'; Test = '$c = "{804A0628-543B-4984-896C-F58BF6A54832}"; -not ((Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$c") -or (Test-Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$c"))'; Apply = '$c = "{804A0628-543B-4984-896C-F58BF6A54832}"; Start-Process -FilePath msiexec.exe -ArgumentList ("/X" + $c + " /qn /norestart") -Wait' }
                @{ Type = 'Exec'; Test = '-not (Test-Path "${env:ProgramFiles(x86)}\WindowsInstallationAssistant\Windows10UpgraderApp.exe")'; Apply = 'Start-Process -FilePath "${env:ProgramFiles(x86)}\WindowsInstallationAssistant\Windows10UpgraderApp.exe" -ArgumentList "/SunValley /ForceUninstall" -Wait' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\UpdateHealthTools'; Op = 'DeleteKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\rempl'; Op = 'DeleteKey'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\CloudManagedUpdate'; Op = 'DeleteKey'; TI = $true }
                
                
                
            )
        }
        @{
            Id = 'feat.internet-explorer-capability'
            Name = 'Remove Browser.InternetExplorer capability'
            Risk = 'low'
            Phase = 30
            Source = 'WH'
            Actions = @(
                @{ Type = 'Capability'; Name = 'Browser.InternetExplorer' }
            )
        }
        @{
            Id = 'feat.powershell-ise-capability'
            Name = 'Remove PowerShell ISE capability'
            Risk = 'low'
            Phase = 30
            Source = 'WH'
            Actions = @(
                @{ Type = 'Capability'; Name = 'Microsoft.Windows.PowerShell.ISE' }
            )
        }
        @{
            Id = 'feat.quick-assist-legacy-capability'
            Name = 'Remove App.Support.QuickAssist (legacy Quick Assist)'
            Risk = 'low'
            Phase = 30
            Source = 'WH'
            Actions = @(
                @{ Type = 'Capability'; Name = 'App.Support.QuickAssist' }
            )
        }
        @{
            Id = 'feat.steps-recorder-capability'
            Name = 'Remove App.StepsRecorder capability'
            Risk = 'low'
            Phase = 30
            Source = 'WH'
            Actions = @(
                @{ Type = 'Capability'; Name = 'App.StepsRecorder' }
            )
        }
        @{
            Id = 'feat.wordpad-capability'
            Name = 'Remove Microsoft.Windows.WordPad capability'
            Risk = 'low'
            Phase = 30
            Source = 'WH'
            Actions = @(
                @{ Type = 'Capability'; Name = 'Microsoft.Windows.WordPad' }
            )
        }
        @{
            Id = 'feat.notepad-legacy-capability'
            Name = 'Remove Microsoft.Windows.Notepad capability (old Win32 Notepad)'
            Risk = 'low'
            Phase = 30
            Source = 'WH'
            Actions = @(
                @{ Type = 'Capability'; Name = 'Microsoft.Windows.Notepad' }
            )
        }
    )
}
