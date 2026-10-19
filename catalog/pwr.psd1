@{
    Tweaks = @(
        @{
            Id = 'pwr.hibernate-off'; Name = 'Disable hibernation and Fast Startup (powercfg /h off, HibernateEnabled=0, HiberbootEnabled=0, ShowHibernateOption=0)'
            Risk = 'med'; Phase = 20; Source = 'RV,RT,WU,WH,OD'
            Note = 'ReviOS default; laptop sleep may overheat. Deletes hiberfil.sys. Revert: powercfg /h on.'
            Actions = @(
                @{
                    Type = 'Exec'
                    Test = '(Get-ItemProperty -LiteralPath "HKLM:\SYSTEM\CurrentControlSet\Control\Power" -Name HibernateEnabled -ErrorAction SilentlyContinue).HibernateEnabled -eq 0'
                    Apply = 'powercfg /h off'
                    Revert = 'powercfg /h on'
                }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power'; Name = 'HiberbootEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings'; Name = 'ShowHibernateOption'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'pwr.high-performance-plan'; Name = 'WinDebloat Ultra Performance power plan (Ultimate Performance duplicate, activated)'
            Risk = 'med'; Phase = 20; Source = 'RV,RT,WU'
            Note = 'Not for laptops. The Revision plan tuning is not available, so this is a plain Ultimate Performance duplicate under a fixed GUID.'
            Actions = @( @{ Type = 'Script'; Script = 'pwr-UltraPlan' } )
        }
        @{
            Id = 'pwr.plan-c6-disable'; Name = 'Ultra Performance plan: deep idle C6 disabled (idle promote/demote 100/80)'
            Risk = 'low'; Phase = 20; Source = 'RT'
            Note = 'Applies to the WinDebloat Ultra Performance plan only; N/A until pwr.high-performance-plan has created it.'
            Actions = @( @{ Type = 'Script'; Script = 'pwr-PlanC6' } )
        }
        @{
            Id = 'pwr.start-power-menu'; Name = 'Start power menu: show Sleep (ShowSleepOption=1)'
            Risk = 'low'; Phase = 10; Source = 'RV,WH'
            Note = 'ShowHibernateOption is handled by pwr.hibernate-off.'
            Actions = @( @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings'; Name = 'ShowSleepOption'; Kind = 'DWord'; Value = 1 } )
        }
        @{
            Id = 'pwr.shutdown-without-logon'; Name = 'Allow shutdown from the logon screen (ShutdownWithoutLogon=1)'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Actions = @( @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'ShutdownWithoutLogon'; Kind = 'DWord'; Value = 1 } )
        }
        @{
            Id = 'pwr.logon-polish'; Name = 'Disable first sign-in animation and startup sound (EnableFirstLogonAnimation=0, DisableStartupSound=1)'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'EnableFirstLogonAnimation'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'DisableStartupSound'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'pwr.crash-control'; Name = 'Auto-reboot after BSOD off, small memory dump (AutoReboot=0, CrashDumpEnabled=3)'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl'; Name = 'AutoReboot'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\CrashControl'; Name = 'CrashDumpEnabled'; Kind = 'DWord'; Value = 3 }
            )
        }
        @{
            Id = 'pwr.hello-logon-fix'; Name = 'Delete DisableAutomaticRestartSignOn (fixes slow Windows Hello logon)'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Actions = @( @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'; Name = 'DisableAutomaticRestartSignOn'; Op = 'DeleteValue' } )
        }
    )
}
