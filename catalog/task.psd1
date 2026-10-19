@{
    Tweaks = @(
        @{
            Id = 'task.application-experience'; Name = 'Disable Application Experience tasks (AitAgent, Compatibility Appraiser, ProgramDataUpdater, MareBackup, StartupAppTask, PcaPatchDbTask)'
            Risk = 'low'; Phase = 20; Source = 'RV,WH,OD'
            Note = 'Explicit names only; absent tasks are N/A.'
            Actions = @(
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Application Experience\'; Name = 'AitAgent'; State = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Application Experience\'; Name = 'Microsoft Compatibility Appraiser'; State = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Application Experience\'; Name = 'ProgramDataUpdater'; State = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Application Experience\'; Name = 'MareBackup'; State = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Application Experience\'; Name = 'StartupAppTask'; State = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Application Experience\'; Name = 'PcaPatchDbTask'; State = 'Disabled' }
            )
        }
        @{
            Id = 'task.ceip'; Name = 'Disable Customer Experience Improvement Program tasks (Consolidator, UsbCeip, KernelCeipTask)'
            Risk = 'low'; Phase = 20; Source = 'RV,WH,OD'
            Actions = @(
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Customer Experience Improvement Program\'; Name = 'Consolidator'; State = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Customer Experience Improvement Program\'; Name = 'UsbCeip'; State = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Customer Experience Improvement Program\'; Name = 'KernelCeipTask'; State = 'Disabled' }
            )
        }
        @{
            Id = 'task.wer-queue'; Name = 'Disable Windows Error Reporting QueueReporting task'
            Risk = 'low'; Phase = 20; Source = 'RV,WH,OD'
            Note = 'Pairs with svc.wersvc.'
            Actions = @( @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Windows Error Reporting\'; Name = 'QueueReporting'; State = 'Disabled' } )
        }
        @{
            Id = 'task.disk-diagnostic'; Name = 'Disable DiskDiagnostic data collector and resolver tasks'
            Risk = 'low'; Phase = 20; Source = 'RV,WH,OD'
            Actions = @(
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\DiskDiagnostic\'; Name = 'Microsoft-Windows-DiskDiagnosticDataCollector'; State = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\DiskDiagnostic\'; Name = 'Microsoft-Windows-DiskDiagnosticResolver'; State = 'Disabled' }
            )
        }
        @{
            Id = 'task.diagnosis-scheduled'; Name = 'Disable \Diagnosis\Scheduled task (scheduled maintenance diagnostics)'
            Risk = 'low'; Phase = 20; Source = 'OD'
            Actions = @( @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Diagnosis\'; Name = 'Scheduled'; State = 'Disabled' } )
        }
        @{
            Id = 'task.power-efficiency'; Name = 'Disable Power Efficiency Diagnostics AnalyzeSystem task'
            Risk = 'low'; Phase = 20; Source = 'RV,WH'
            Actions = @( @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Power Efficiency Diagnostics\'; Name = 'AnalyzeSystem'; State = 'Disabled' } )
        }
        @{
            Id = 'task.memory-diagnostic'; Name = 'Disable MemoryDiagnostic ProcessMemoryDiagnosticEvents and RunFullMemoryDiagnostic tasks'
            Risk = 'low'; Phase = 20; Source = 'RV'
            Actions = @(
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\MemoryDiagnostic\'; Name = 'ProcessMemoryDiagnosticEvents'; State = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\MemoryDiagnostic\'; Name = 'RunFullMemoryDiagnostic'; State = 'Disabled' }
            )
        }
        @{
            Id = 'task.feedback-siuf'; Name = 'Disable Feedback\Siuf DmClient and DmClientOnScenarioDownload tasks'
            Risk = 'low'; Phase = 20; Source = 'WH,OD'
            Actions = @(
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Feedback\Siuf\'; Name = 'DmClient'; State = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\Feedback\Siuf\'; Name = 'DmClientOnScenarioDownload'; State = 'Disabled' }
            )
        }
        @{
            Id = 'task.sqm'; Name = 'Disable PI\Sqm-Tasks (software quality metrics) task'
            Risk = 'low'; Phase = 20; Source = 'WH'
            Actions = @( @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\PI\'; Name = 'Sqm-Tasks'; State = 'Disabled' } )
        }
        @{
            Id = 'task.office'; Name = 'Disable all scheduled tasks under \Microsoft\Office\ (telemetry, Office Actions Server)'
            Risk = 'low'; Phase = 20; Source = 'RV,WH'
            Note = 'Enumerated at runtime; N/A when Office is not installed.'
            Actions = @( @{ Type = 'ScheduledTask'; Path = '\Microsoft\Office\'; Name = '*'; State = 'Disabled' } )
        }
        @{
            Id = 'task.ucpd-velocity'; Name = 'Disable AppxDeploymentClient\UCPD velocity task'
            Risk = 'low'; Phase = 20; Source = 'RV'
            Note = 'Pair with svc.ucpd, else the task re-enables the driver. Windows updates can re-enable it (drift).'
            Actions = @( @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\AppxDeploymentClient\'; Name = 'UCPD velocity'; State = 'Disabled' } )
        }
        @{
            Id = 'task.windows-ai-recall'; Name = 'Disable WindowsAI RecallConfiguration and RecallPipeline tasks'
            Risk = 'low'; Phase = 20; Source = 'WH'
            Note = 'N/A when Recall tasks are absent.'
            Actions = @(
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\WindowsAI\'; Name = 'RecallConfiguration'; State = 'Disabled' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Windows\WindowsAI\'; Name = 'RecallPipeline'; State = 'Disabled' }
            )
        }
        @{
            Id = 'task.etw-diagnostic-channels'; Name = 'Turn off SleepStudy, Kernel-Processor-Power and UserModePowerService diagnostic ETW channels'
            Risk = 'low'; Phase = 20; Source = 'RV'
            Note = 'wevtutil, not a task. Revert re-enables the channels.'
            Actions = @(
                @{
                    Type = 'Exec'
                    Test = '$r = $true; foreach ($c in @("Microsoft-Windows-SleepStudy/Diagnostic", "Microsoft-Windows-Kernel-Processor-Power/Diagnostic", "Microsoft-Windows-UserModePowerService/Diagnostic")) { $o = @(wevtutil gl $c 2>$null); if ($LASTEXITCODE -eq 0 -and @($o | Where-Object { $_ -match "^enabled:\s*true" }).Count -gt 0) { $r = $false } }; $r'
                    Apply = 'foreach ($c in @("Microsoft-Windows-SleepStudy/Diagnostic", "Microsoft-Windows-Kernel-Processor-Power/Diagnostic", "Microsoft-Windows-UserModePowerService/Diagnostic")) { wevtutil sl $c /q:false 2>$null | Out-Null; wevtutil sl $c /e:false 2>$null | Out-Null }'
                    Revert = 'foreach ($c in @("Microsoft-Windows-SleepStudy/Diagnostic", "Microsoft-Windows-Kernel-Processor-Power/Diagnostic", "Microsoft-Windows-UserModePowerService/Diagnostic")) { wevtutil sl $c /e:true 2>$null | Out-Null }'
                }
            )
        }
    )
}
