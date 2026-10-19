@{
    Tweaks = @(
        @{
            Id = 'perf.win32-priority-separation'; Name = 'Win32PrioritySeparation=38 (short variable quantum, 3x foreground boost)'
            Risk = 'low'; Phase = 10; Source = 'RV,OD,WH'
            Note = '38 is the WH "Programs" option; 24 = background services. Revert value 2.'
            Actions = @( @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl'; Name = 'Win32PrioritySeparation'; Kind = 'DWord'; Value = 38 } )
        }
        @{
            Id = 'perf.mmcss-tuning'; Name = 'MMCSS multimedia scheduler: SystemResponsiveness=10, NoLazyMode, AlwaysOn, Games task Priority/Scheduling/SFIO/GPU Priority'
            Risk = 'low'; Phase = 10; Source = 'OD,WH,RV'
            Note = 'Games Priority uses the WH value 6 (OD uses 2). NetworkThrottlingIndex is in perf.network-throttling-index.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'; Name = 'SystemResponsiveness'; Kind = 'DWord'; Value = 10 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'; Name = 'NoLazyMode'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'; Name = 'AlwaysOn'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'; Name = 'Priority'; Kind = 'DWord'; Value = 6 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'; Name = 'Scheduling Category'; Kind = 'String'; Value = 'High' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'; Name = 'SFIO Priority'; Kind = 'String'; Value = 'High' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games'; Name = 'GPU Priority'; Kind = 'DWord'; Value = 8 }
            )
        }
        @{
            Id = 'perf.network-throttling-index'; Name = 'NetworkThrottlingIndex=10 (ReviOS value, Windows default)'
            Risk = 'low'; Phase = 10; Source = 'RV,OD'
            Note = 'Conflict: RV 10 (default) vs OD 0xFFFFFFFF (off); the ReviOS value is used.'
            Actions = @( @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'; Name = 'NetworkThrottlingIndex'; Kind = 'DWord'; Value = 10 } )
        }
        @{
            Id = 'perf.ntfs-last-access-off'; Name = 'NTFS last-access timestamp updates disabled (fsutil disablelastaccess 1)'
            Risk = 'low'; Phase = 20; Source = 'RV,RT'
            Note = 'Revert restores the system-managed default (2).'
            Actions = @(
                @{
                    Type = 'Exec'
                    Test = '$o = (fsutil behavior query disablelastaccess 2>$null | Out-String); $o -match "=\s*[13]\b"'
                    Apply = 'fsutil behavior set disablelastaccess 1 | Out-Null'
                    Revert = 'fsutil behavior set disablelastaccess 2 | Out-Null'
                }
            )
        }
        @{
            Id = 'perf.superfetch-keep'; Name = 'Keep SysMain/Superfetch enabled (SysMain Automatic, rdyboost Boot, EnablePrefetcher/EnableSuperfetch=3)'
            Risk = 'low'; Phase = 20; Source = 'RV'
            Note = 'Asserts the default state; ReviOS revert (disabling breaks defrag c: -b). Conflicts with svc.sysmain-off and perf.prefetch.'
            Actions = @(
                @{ Type = 'Service'; Name = 'SysMain'; Start = 'Automatic' }
                @{ Type = 'Service'; Name = 'rdyboost'; Start = 'Boot' }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters'; Name = 'EnablePrefetcher'; Kind = 'DWord'; Value = 3 }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters'; Name = 'EnableSuperfetch'; Kind = 'DWord'; Value = 3 }
            )
        }
        @{
            Id = 'perf.ifeo-perfoptions'; Name = 'IFEO PerfOptions, safe subset: SearchIndexer and ctfmon CPU BelowNormal, fontdrvhost Idle/VeryLow IO'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Note = 'Narrowed by user decision: lsass.exe and sihost.exe are deliberately NOT written.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\SearchIndexer.exe\PerfOptions'; Name = 'CpuPriorityClass'; Kind = 'DWord'; Value = 5; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\ctfmon.exe\PerfOptions'; Name = 'CpuPriorityClass'; Kind = 'DWord'; Value = 5; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\fontdrvhost.exe\PerfOptions'; Name = 'CpuPriorityClass'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\fontdrvhost.exe\PerfOptions'; Name = 'IoPriority'; Kind = 'DWord'; Value = 0; TI = $true }
            )
        }
        @{
            Id = 'perf.shutdown-timeouts'; Name = 'Fast shutdown: AutoEndTasks=1, HungAppTimeout/WaitToKillAppTimeout=2000, LowLevelHooksTimeout=1000, WaitToKillServiceTimeout=1500'
            Risk = 'med'; Phase = 10; Source = 'RV'
            Note = 'Can truncate saves at shutdown.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Desktop'; Name = 'AutoEndTasks'; Kind = 'String'; Value = '1' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Desktop'; Name = 'HungAppTimeout'; Kind = 'String'; Value = '2000' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Desktop'; Name = 'WaitToKillAppTimeout'; Kind = 'String'; Value = '2000' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Desktop'; Name = 'LowLevelHooksTimeout'; Kind = 'String'; Value = '1000' }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control'; Name = 'WaitToKillServiceTimeout'; Kind = 'String'; Value = '1500' }
            )
        }
        @{
            Id = 'perf.menu-responsiveness'; Name = 'MenuShowDelay=0, ActiveWndTrkTimeout=10'
            Risk = 'low'; Phase = 10; Source = 'RV,OD,WH'
            Note = 'MouseHoverTime deliberately left at 400.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Desktop'; Name = 'MenuShowDelay'; Kind = 'String'; Value = '0' }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\Desktop'; Name = 'ActiveWndTrkTimeout'; Kind = 'DWord'; Value = 10 }
            )
        }
        @{
            Id = 'perf.explorer-folder-discovery-off'; Name = 'Disable automatic folder type discovery (FolderType=NotSpecified)'
            Risk = 'low'; Phase = 10; Source = 'RV,WU'
            Note = 'Needs sign-out. Bags/BagMRU are not cleared.'
            Actions = @( @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell'; Name = 'FolderType'; Kind = 'String'; Value = 'NotSpecified' } )
        }
        @{
            Id = 'perf.explorer-high-perf-gpu'; Name = 'Explorer uses the high-performance GPU (UserGpuPreferences GpuPreference=2)'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Note = 'Hybrid-graphics laptops: battery cost.'
            Actions = @( @{ Type = 'Registry'; Path = 'HKCU\Software\Microsoft\DirectX\UserGpuPreferences'; Name = 'C:\Windows\explorer.exe'; Kind = 'String'; Value = 'GpuPreference=2;' } )
        }
        @{
            Id = 'perf.search-indexing-power'; Name = 'Search indexing respects power modes; no indexing on battery'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex'; Name = 'RespectPowerModes'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'PreventIndexOnBattery'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'perf.disable-low-disk-checks'; Name = 'NoLowDiskSpaceChecks=1'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Actions = @( @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoLowDiskSpaceChecks'; Kind = 'DWord'; Value = 1 } )
        }
        @{
            Id = 'perf.no-track-shortcuts'; Name = 'LinkResolveIgnoreLinkInfo=1 and NoResolveSearch=1 (stop shell shortcut tracking)'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'LinkResolveIgnoreLinkInfo'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoResolveSearch'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'perf.disable-autochk'; Name = 'Exclude C: from boot-time autochk (BootExecute autocheck autochk /k:C*)'
            Risk = 'med'; Phase = 10; Source = 'RV'
            Note = 'No automatic chkdsk of C: after an unclean shutdown. Revert value: autocheck autochk *'
            Actions = @( @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager'; Name = 'BootExecute'; Kind = 'MultiString'; Value = @('autocheck autochk /k:C*') } )
        }
        @{
            Id = 'perf.disable-wpbt'; Name = 'DisableWpbtExecution=1 (stop OEM firmware injecting binaries at boot)'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Actions = @( @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager'; Name = 'DisableWpbtExecution'; Kind = 'DWord'; Value = 1 } )
        }
        @{
            Id = 'perf.reserved-storage-off'; Name = 'Reserved Storage disabled (ShippedWithReserves=0, Set-WindowsReservedStorageState)'
            Risk = 'low'; Phase = 20; Source = 'RV'
            Note = 'Frees ~7 GB; Windows Update may re-enable. State check needs admin (Unknown unelevated).'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager'; Name = 'ShippedWithReserves'; Kind = 'DWord'; Value = 0 }
                @{
                    Type = 'Exec'
                    Test = '(Get-WindowsReservedStorageState | Out-String) -match "Disabled"'
                    Apply = 'Set-WindowsReservedStorageState -State Disabled'
                    Revert = 'Set-WindowsReservedStorageState -State Enabled'
                }
            )
        }
        @{
            Id = 'perf.copy-dialog-details'; Name = 'Show more details in the copy dialog (EnthusiastMode=1)'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Actions = @( @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager'; Name = 'EnthusiastMode'; Kind = 'DWord'; Value = 1 } )
        }
    )
}
