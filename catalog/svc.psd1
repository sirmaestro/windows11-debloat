@{
    Tweaks = @(
        @{
            Id = 'svc.reviOS-service-set'; Name = 'ReviOS service set (dam, GpuEnergyDrv, NetBT, Telemetry, diagnosticshub, WerSvc, DiagTrack, wisvc, PcaSvc, Wdi hosts, tcpipreg, Wecsvc, UCPD disabled; edgeupdate Manual; condrv Automatic)'
            Risk = 'med'; Phase = 20; Source = 'RV'; Reboot = $true
            Note = 'Bundle; the individual svc.* items below are idempotent copies. Absent services are N/A.'
            Actions = @(
                @{ Type = 'Service'; Name = 'dam'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'GpuEnergyDrv'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'NetBT'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'Telemetry'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'diagnosticshub.standardcollector.service'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'WerSvc'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'DiagTrack'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'wisvc'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'PcaSvc'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'WdiServiceHost'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'WdiSystemHost'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'tcpipreg'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'edgeupdate'; Start = 'Manual' }
                @{ Type = 'Service'; Name = 'Wecsvc'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'UCPD'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'condrv'; Start = 'Automatic' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\AppxDeploymentClient\'; Name = 'UCPD velocity'; State = 'Disabled' }
            )
        }
        @{
            Id = 'svc.diagtrack'; Name = 'Connected User Experiences & Telemetry (DiagTrack): Disabled'
            Risk = 'low'; Phase = 20; Source = 'RV,WU,WH,OD'
            Note = 'In RV set. Default Automatic.'
            Actions = @( @{ Type = 'Service'; Name = 'DiagTrack'; Start = 'Disabled'; StopNow = $true } )
        }
        @{
            Id = 'svc.diagnosticshub'; Name = 'Diagnostics Hub standard collector service: Disabled'
            Risk = 'low'; Phase = 20; Source = 'RV,OD'
            Note = 'In RV set. Default Manual.'
            Actions = @( @{ Type = 'Service'; Name = 'diagnosticshub.standardcollector.service'; Start = 'Disabled' } )
        }
        @{
            Id = 'svc.wersvc'; Name = 'Windows Error Reporting service (WerSvc): Disabled'
            Risk = 'low'; Phase = 20; Source = 'RV,WU,WH,OD,RS'
            Note = 'In RV set. Pair with task.wer-queue. Default Manual.'
            Actions = @( @{ Type = 'Service'; Name = 'WerSvc'; Start = 'Disabled' } )
        }
        @{
            Id = 'svc.pcasvc'; Name = 'Program Compatibility Assistant service: Disabled'
            Risk = 'low'; Phase = 20; Source = 'RV,WH,OD'
            Note = 'In RV set. No more compatibility prompts. Default Manual.'
            Actions = @( @{ Type = 'Service'; Name = 'PcaSvc'; Start = 'Disabled' } )
        }
        @{
            Id = 'svc.wisvc'; Name = 'Windows Insider service: Disabled'
            Risk = 'low'; Phase = 20; Source = 'RV,WH,RS'
            Note = 'In RV set. Only affects Insider enrolment.'
            Actions = @( @{ Type = 'Service'; Name = 'wisvc'; Start = 'Disabled' } )
        }
        @{
            Id = 'svc.wdi-hosts'; Name = 'Diagnostic Service Host and Diagnostic System Host: Disabled'
            Risk = 'low'; Phase = 20; Source = 'RV'
            Note = 'In RV set. Disables troubleshooter diagnostics.'
            Actions = @(
                @{ Type = 'Service'; Name = 'WdiServiceHost'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'WdiSystemHost'; Start = 'Disabled' }
            )
        }
        @{
            Id = 'svc.dam'; Name = 'Desktop Activity Moderator driver (dam): Disabled'
            Risk = 'med'; Phase = 20; Source = 'RV'; Reboot = $true
            Note = 'In RV set. Kernel driver, default System (1).'
            Actions = @( @{ Type = 'Service'; Name = 'dam'; Start = 'Disabled' } )
        }
        @{
            Id = 'svc.gpuenergydrv'; Name = 'GPU energy telemetry driver (GpuEnergyDrv): Disabled'
            Risk = 'low'; Phase = 20; Source = 'RV'; Reboot = $true
            Note = 'In RV set. Default Manual.'
            Actions = @( @{ Type = 'Service'; Name = 'GpuEnergyDrv'; Start = 'Disabled' } )
        }
        @{
            Id = 'svc.netbt'; Name = 'NetBIOS over TCP/IP driver (NetBT): Disabled'
            Risk = 'med'; Phase = 20; Source = 'RV'; Reboot = $true
            Note = 'In RV set. Breaks legacy SMB/NetBIOS name resolution. Default System (1).'
            Actions = @( @{ Type = 'Service'; Name = 'NetBT'; Start = 'Disabled' } )
        }
        @{
            Id = 'svc.intel-telemetry'; Name = 'Intel telemetry service (Telemetry): Disabled'
            Risk = 'low'; Phase = 20; Source = 'RV'
            Note = 'In RV set. N/A when the Intel service is absent.'
            Actions = @( @{ Type = 'Service'; Name = 'Telemetry'; Start = 'Disabled' } )
        }
        @{
            Id = 'svc.tcpipreg-wecsvc'; Name = 'tcpipreg (experimental) and Windows Event Collector (Wecsvc): Disabled'
            Risk = 'low'; Phase = 20; Source = 'RV'
            Note = 'In RV set. Default Manual.'
            Actions = @(
                @{ Type = 'Service'; Name = 'tcpipreg'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'Wecsvc'; Start = 'Disabled' }
            )
        }
        @{
            Id = 'svc.ucpd'; Name = 'User Choice Protection Driver (UCPD) disabled so default-app hashes can be changed'
            Risk = 'med'; Phase = 20; Source = 'RV'; Reboot = $true
            Note = 'In RV set. Also disables the UCPD velocity task. Windows updates can re-enable it (drift).'
            Actions = @(
                @{ Type = 'Service'; Name = 'UCPD'; Start = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\AppxDeploymentClient\'; Name = 'UCPD velocity'; State = 'Disabled' }
            )
        }
        @{
            Id = 'svc.edgeupdate-manual'; Name = 'Edge Update service (edgeupdate): Manual, not Disabled'
            Risk = 'low'; Phase = 20; Source = 'RV'
            Note = 'In RV set. Disabled would break WebView2 installs via Visual Studio. Default Automatic (delayed).'
            Actions = @( @{ Type = 'Service'; Name = 'edgeupdate'; Start = 'Manual' } )
        }
        @{
            Id = 'svc.condrv-auto'; Name = 'Console driver (condrv): Automatic'
            Risk = 'low'; Phase = 20; Source = 'RV'
            Note = 'In RV set. Fixes error 0xd000003a. Default Manual.'
            Actions = @( @{ Type = 'Service'; Name = 'condrv'; Start = 'Automatic' } )
        }
        @{
            Id = 'svc.remote-registry'; Name = 'Remote Registry service: Disabled'
            Risk = 'low'; Phase = 20; Source = 'OD,RS'
            Note = 'Breaks remote regedit/admin tools.'
            Actions = @( @{ Type = 'Service'; Name = 'RemoteRegistry'; Start = 'Disabled' } )
        }
        @{
            Id = 'svc.ai-fabric'; Name = 'Windows AI Fabric service (WSAIFabricSvc): Disabled'
            Risk = 'low'; Phase = 20; Source = 'WU,WH'
            Note = 'Complements the AI group. Default Automatic. N/A when absent.'
            Actions = @( @{ Type = 'Service'; Name = 'WSAIFabricSvc'; Start = 'Disabled' } )
        }
        @{
            Id = 'svc.msi-safeboot'; Name = 'Allow Windows Installer (MSIServer) to run in Safe Mode'
            Risk = 'low'; Phase = 10; Source = 'RV'
            Note = 'SafeBoot Minimal and Network keys, default value = Service.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Minimal\MSIServer'; Name = ''; Kind = 'String'; Value = 'Service' }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\SafeBoot\Network\MSIServer'; Name = ''; Kind = 'String'; Value = 'Service' }
            )
        }
    )
}
