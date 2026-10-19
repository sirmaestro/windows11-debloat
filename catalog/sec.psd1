# Security tweaks (group 1). sec.defender-disable is implemented separately.
@{
    Tweaks = @(
        @{
            Id = 'sec.defender-ui-hide'
            Name = 'Hide Defender systray, remove SecurityHealth Run entry, silence account-protection nag'
            Risk = 'low'
            Phase = 10
            Source = 'RV,WH'
            Note = 'Pairs with sec.defender-disable. The Windows Security toast switches (WH) are not touched.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray'; Name = 'HideSystray'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'; Name = 'SecurityHealth'; Op = 'DeleteValue' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows Security Health\State'; Name = 'AccountProtection_MicrosoftAccount_Disconnected'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'sec.smartscreen-off'
            Name = 'SmartScreen off: app install control, web content evaluation, Edge phishing filter'
            Risk = 'med'
            Phase = 10
            Source = 'RV,RT'
            Note = 'RV set only; smartscreen.exe rename/IFEO from the RT Defender flow is not applied.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen'; Name = 'ConfigureAppInstallControlEnabled'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\SmartScreen'; Name = 'ConfigureAppInstallControl'; Kind = 'String'; Value = 'Anywhere'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost'; Name = 'EnableWebContentEvaluation'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\MicrosoftEdge\PhishingFilter'; Name = 'EnabledV9'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'sec.smart-app-control-off'
            Name = 'Smart App Control Off (VerifiedAndReputablePolicyState=0)'
            Risk = 'high'
            Phase = 10
            Source = 'WH'
            Note = 'One-way: once Off it cannot be turned back on without a reset/reinstall.'
            Reboot = $true
            Builds = @{ Min = 22621 }
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy'; Name = 'VerifiedAndReputablePolicyState'; Kind = 'DWord'; Value = 0; TI = $true }
            )
        }
        @{
            Id = 'sec.vbs-off'
            Name = 'Disable Virtualization-Based Security (bcdedit vsmlaunchtype off, DeviceGuard policy and control keys)'
            Risk = 'high'
            Phase = 20
            Source = 'RV,RT,WH'
            Note = 'Gaming performance gain; lowers security. If VBS is UEFI-locked the registry alone is not enough. Memory integrity is in sec.hvci-off.'
            Reboot = $true
            Actions = @(
                @{ Type = 'Bcdedit'; Name = 'vsmlaunchtype'; Value = 'off' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name = 'EnableVirtualizationBasedSecurity'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name = 'LsaCfgFlags'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard'; Name = 'HVCIMATRequired'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Control\DeviceGuard'; Name = 'EnableVirtualizationBasedSecurity'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Control\DeviceGuard'; Name = 'Mandatory'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Control\DeviceGuard'; Name = 'HVCIMATRequired'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'sec.hvci-off'
            Name = 'Disable Memory Integrity / HVCI (HypervisorEnforcedCodeIntegrity Enabled=0)'
            Risk = 'high'
            Phase = 10
            Source = 'RV,RT,WH'
            Note = 'Does not touch VulnerableDriverBlocklistEnable (ReviOS reverted that: it breaks THE FINALS).'
            Reboot = $true
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'; Name = 'WasEnabledBy'; Op = 'DeleteValue' }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity'; Name = 'ChangedInBootCycle'; Op = 'DeleteValue' }
            )
        }
        @{
            Id = 'sec.autoplay-off'
            Name = 'AutoPlay/AutoRun off for all drives'
            Risk = 'low'
            Phase = 10
            Source = 'RV,WH'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoDriveTypeAutoRun'; Kind = 'DWord'; Value = 255 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoDriveTypeAutoRun'; Kind = 'DWord'; Value = 255 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers'; Name = 'DisableAutoplay'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'sec.show-file-extensions'
            Name = 'Show file extensions (HideFileExt=0)'
            Risk = 'low'
            Phase = 50
            Source = 'RV'
            Note = 'May be duplicated in the shell group; harmless.'
            RestartExplorer = $true
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'HideFileExt'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'sec.linked-connections'
            Name = 'Mapped network drives visible to elevated processes (EnableLinkedConnections=1)'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Reboot = $true
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'EnableLinkedConnections'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'sec.bitlocker-auto-encrypt-off'
            Name = 'Prevent automatic BitLocker device encryption (PreventDeviceEncryption=1)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,WU,WH'
            Note = 'No effect once encryption is already active.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\BitLocker'; Name = 'PreventDeviceEncryption'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'sec.password-never-expires'
            Name = 'Local accounts: maximum password age unlimited (net accounts /maxpwage:unlimited)'
            Risk = 'low'
            Phase = 20
            Source = 'RV,WU'
            Note = 'Test reads the third line of net accounts (works in any language: no digits means unlimited).'
            Actions = @(
                @{ Type = 'Exec'; Test = '$l = @(net accounts)[2]; $l -notmatch ''\d'''; Apply = 'net accounts /maxpwage:unlimited | Out-Null'; Revert = 'net accounts /maxpwage:42 | Out-Null' }
            )
        }
        @{
            Id = 'sec.refresh-root-certs'
            Name = 'Refresh trusted root certificates from Windows Update (one-shot)'
            Risk = 'low'
            Phase = 20
            Source = 'RT'
            Note = 'Does not set DisableRootAutoUpdate (the Store needs it). Marker value: HKLM\SOFTWARE\WinDebloat\State\RootCertsRefreshed.'
            Actions = @(
                @{ Type = 'Script'; Script = 'sec-RefreshRootCerts' }
            )
        }
        @{
            Id = 'sec.workplace-join-prompts-off'
            Name = 'Block "Allow my organization to manage my device" workplace-join prompts'
            Risk = 'med'
            Phase = 10
            Source = 'WH'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin'; Name = 'BlockAADWorkplaceJoin'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin'; Name = 'BlockAADWorkplaceJoin'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'sec.ps-execution-policy'
            Name = 'PowerShell execution policy RemoteSigned (user and machine)'
            Risk = 'med'
            Phase = 10
            Source = 'WH'
            Note = 'Windows default is Restricted.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell'; Name = 'ExecutionPolicy'; Kind = 'String'; Value = 'RemoteSigned' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell'; Name = 'ExecutionPolicy'; Kind = 'String'; Value = 'RemoteSigned' }
            )
        }
    )
}
