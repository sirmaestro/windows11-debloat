@{
    Tweaks = @(
        @{
            Id = 'ctx.legacy-menu'; Name = 'Classic Win10 right-click menu'; Risk = 'low'; Phase = 50; Source = 'RV,WU,OD,WH'; RestartExplorer = $true
            Note = 'Empty InprocServer32 default value; revert removes it'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'; Op = 'EnsureKey' }
                @{ Type = 'Registry'; Path = 'HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32'; Name = ''; Kind = 'String'; Value = '' }
            )
        }
        @{
            Id = 'ctx.open-with-store-lookup-off'; Name = 'Remove "Look for an app in the Store" in Open with'; Risk = 'low'; Phase = 10; Source = 'RV'
            Note = 'NoInternetOpenWith=1 in HKCU and HKLM'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoInternetOpenWith'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoInternetOpenWith'; Kind = 'DWord'; Value = 1; TI = $true }
            )
        }
    )
}

