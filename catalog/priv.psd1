# Privacy & telemetry tweaks (group 1). Generated from docs/tweaks/group1.mech.md.
@{
    Tweaks = @(
        @{
            Id = 'priv.telemetry-policy'
            Name = 'Telemetry level 0 (policy + CPSS)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,RT,OD,WU,WH'
            Note = 'Home/Pro still send Required data; 0 acts as the minimum. Services DiagTrack/dmwappushservice are in the svc group.'
            Reboot = $true
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'AllowTelemetry'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'AllowTelemetry'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; Name = 'AllowTelemetry'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; Name = 'AllowTelemetry'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowTelemetry'; Name = 'value'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\DevicePolicy\AllowTelemetry'; Name = 'DefaultValue'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\Store\AllowTelemetry'; Name = 'Value'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; Name = 'AllowTelemetry'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; Name = 'MaxTelemetryAllowed'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection'; Name = 'MaxTelemetryAllowed'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack'; Name = 'ShowedToastAtLevel'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'priv.datacollection-hardening'
            Name = 'DataCollection policy hardening (commercial pipeline, device name, feedback UX, flighting, dumps)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,RT,OD,WH'
            Note = 'Companion to priv.telemetry-policy.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'AllowCommercialDataPipeline'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'AllowDeviceNameInTelemetry'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'DisableEnterpriseAuthProxy'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'MicrosoftEdgeDataOptIn'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'DisableTelemetryOptInChangeNotification'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'DisableTelemetryOptInSettingsUx'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'DoNotShowFeedbackNotifications'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'LimitEnhancedDiagnosticDataWindowsAnalytics'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'AllowBuildPreview'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'LimitDiagnosticLogCollection'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'LimitDumpCollection'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds'; Name = 'EnableConfigFlighting'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System'; Name = 'AllowExperimentation'; Kind = 'DWord'; Value = 0; TI = $true }
            )
        }
        @{
            Id = 'priv.autologgers-off'
            Name = 'Telemetry ETW autologgers off (Diagtrack-Listener, SQMLogger, SetupPlatformTel)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD'
            Note = 'RV set of 3 sessions; OD extras not applied. Absent sessions are N/A.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\Diagtrack-Listener'; Name = 'Start'; Kind = 'DWord'; Value = 0; TI = $true; RequireKey = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\SQMLogger'; Name = 'Start'; Kind = 'DWord'; Value = 0; TI = $true; RequireKey = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\SetupPlatformTel'; Name = 'Start'; Kind = 'DWord'; Value = 0; TI = $true; RequireKey = $true }
            )
        }
        @{
            Id = 'priv.appcompat-policy'
            Name = 'Application Compatibility telemetry off (engine, inventory, PCA, steps recorder)'
            Risk = 'med'
            Phase = 10
            Source = 'RV,OD,WH'
            Note = 'DisableEngine=1 can stop legacy compat shims from applying.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat'; Name = 'DisableEngine'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat'; Name = 'AITEnable'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat'; Name = 'DisableUAR'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat'; Name = 'DisablePCA'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat'; Name = 'DisableInventory'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AppCompat'; Name = 'SbEnable'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'priv.ceip-off'
            Name = 'Customer Experience Improvement Program / SQM disabled'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Note = 'CEIP scheduled tasks are in the task group.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\SQMClient\Windows'; Name = 'CEIPEnable'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\AppV\CEIP'; Name = 'CEIPEnable'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Internet Explorer\SQM'; Name = 'DisableCustomerImprovementProgram'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Messenger\Client'; Name = 'CEIP'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\UnattendSettings\SQMClient'; Name = 'CEIPEnabled'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'priv.content-delivery-off'
            Name = 'Content Delivery Manager off (silent installs, tips, suggestions, spotlight)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WH,WU'
            Note = 'Also deletes the Subscriptions and SuggestedApps subkeys.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'ContentDeliveryAllowed'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContentEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-310093Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338387Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338388Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338389Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-338393Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-353694Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-353696Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-314559Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280815Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-314563Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-202914Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280810Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-280811Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'; Name = 'SubscribedContent-353698Enabled'; Kind = 'DWord'; Value = 0 }
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
            )
        }
        @{
            Id = 'priv.cloudcontent-policies'
            Name = 'CloudContent/Spotlight policies (soft landing, third-party suggestions, cloud-optimized content, Spotlight)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WU'
            Note = 'Does not set DisableWindowsConsumerFeatures (see priv.consumer-features-policy).'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableSoftLanding'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableTailoredExperiencesWithDiagnosticData'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableCloudOptimizedContent'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableConsumerAccountStateContent'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableThirdPartySuggestions'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'ConfigureWindowsSpotlight'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'IncludeEnterpriseSpotlight'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableThirdPartySuggestions'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableTailoredExperiencesWithDiagnosticData'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsSpotlightFeatures'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsSpotlightWindowsWelcomeExperience'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsSpotlightOnActionCenter'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableWindowsSpotlightOnSettings'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'priv.restrict-internet-comm'
            Name = 'Restrict Internet communication policies (publishing wizard, web services, HTTP printing, PCHealth, registration)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD'
            Note = 'Does not write the old RestrictCommunication key.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoPublishingWizard'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoWebServices'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoOnlinePrintsWizard'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoInternetOpenWith'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoPublishingWizard'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoWebServices'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoOnlinePrintsWizard'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'NoInternetOpenWith'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\CurrentVersion\Software Protection Platform'; Name = 'NoGenTicket'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers'; Name = 'DisableHTTPPrinting'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Printers'; Name = 'DisableWebPnPDownload'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\HandwritingErrorReports'; Name = 'PreventHandwritingErrorReports'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\TabletPC'; Name = 'PreventHandwritingDataSharing'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\PCHealth\HelpSvc'; Name = 'Headlines'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\PCHealth\HelpSvc'; Name = 'MicrosoftKBSearch'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\PCHealth\ErrorReporting'; Name = 'DoReport'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Internet Connection Wizard'; Name = 'ExitOnMSICW'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\EventViewer'; Name = 'MicrosoftEventVwrDisableLinks'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Registration Wizard Control'; Name = 'NoRegistration'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\SearchCompanion'; Name = 'DisableContentFileUpdates'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0'; Name = 'NoOnlineAssist'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0'; Name = 'NoExplicitFeedback'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0'; Name = 'NoImplicitFeedback'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Assistance\Client\1.0'; Name = 'NoActiveHelp'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\WindowsMovieMaker'; Name = 'WebHelp'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\WindowsMovieMaker'; Name = 'CodecDownload'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\WindowsMovieMaker'; Name = 'WebPublish'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'priv.error-reporting-off'
            Name = 'Windows Error Reporting disabled (policy, consent, dumps)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WH'
            Note = 'WerSvc/PcaSvc and WER tasks are in the svc/task groups. Handwriting error reports are in priv.restrict-internet-comm.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name = 'AutoApproveOSDumps'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name = 'LoggingDisabled'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name = 'Disabled'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name = 'DontSendAdditionalData'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name = 'DontShowUI'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting'; Name = 'Disabled'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent'; Name = 'DefaultConsent'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Consent'; Name = 'DefaultOverrideBehavior'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting\Consent'; Name = '0'; Kind = 'String'; Value = '' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting'; Name = 'Disabled'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'priv.firewall-telemetry-block'
            Name = 'Outbound firewall rules blocking DiagTrack and WerSvc svchost to the Internet'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Note = 'No Windows-Insider (wisvc) rule: it breaks Xbox. Windows Firewall itself is left on.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Defaults\FirewallPolicy\FirewallRules'; Name = 'Block-Unified-Telemetry-Client'; Kind = 'String'; Value = 'v2.31|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=%SystemRoot%\system32\svchost.exe|Svc=DiagTrack|Name=Block-Unified-Telemetry-Client|Desc=Block-Unified-Telemetry-Client|EmbedCtxt=DiagTrack|'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Defaults\FirewallPolicy\FirewallRules'; Name = 'Block-Windows-Error-Reporting'; Kind = 'String'; Value = 'v2.31|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=%SystemRoot%\system32\svchost.exe|Svc=WerSvc|Name=Block-Unified-Error-Reporting|Desc=Block-Windows-Error-Reporting|EmbedCtxt=WerSvc|'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules'; Name = 'Block-Unified-Telemetry-Client'; Kind = 'String'; Value = 'v2.31|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=%SystemRoot%\system32\svchost.exe|Svc=DiagTrack|Name=Block-Unified-Telemetry-Client|Desc=Block-Unified-Telemetry-Client|EmbedCtxt=DiagTrack|'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Parameters\FirewallPolicy\FirewallRules'; Name = 'Block-Windows-Error-Reporting'; Kind = 'String'; Value = 'v2.31|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=%SystemRoot%\system32\svchost.exe|Svc=WerSvc|Name=Block-Unified-Telemetry-Client|Desc=Block-Windows-Error-Reporting|EmbedCtxt=WerSvc|'; TI = $true }
            )
        }
        @{
            Id = 'priv.hosts-telemetry-blocklist'
            Name = 'Hosts blocklist for Microsoft telemetry/Watson/ads and VS telemetry (managed block, file kept)'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Note = 'Appends a marked block to hosts; never replaces the file. Brave hosts deliberately excluded.'
            Actions = @(
                @{ Type = 'Hosts'; Name = 'telemetry'; Entries = @('browser.pipe.aria.microsoft.com', 'dmd.metaservices.microsoft.com', 'ris.api.iris.microsoft.com', 'teams.events.data.microsoft.com', 'telecommand.telemetry.microsoft.com', 'telemetry.microsoft.com', 'vortex-win.data.microsoft.com', 'watson.events.data.microsoft.com', 'activity.windows.com', 'outlookads.live.com', 'watson.microsoft.com', 'watson.telemetry.microsoft.com', 'umwatsonc.events.data.microsoft.com', 'ceuswatcab01.blob.core.windows.net', 'ceuswatcab02.blob.core.windows.net', 'eaus2watcab01.blob.core.windows.net', 'eaus2watcab02.blob.core.windows.net', 'weus2watcab01.blob.core.windows.net', 'weus2watcab02.blob.core.windows.net', 'events-sandbox.data.microsoft.com', 'events.data.microsoft.com', 'v10.events.data.microsoft.com', 'v20.events.data.microsoft.com', 'v10c.events.data.microsoft.com', 'v10.vortex-win.data.microsoft.com', 'eu-v10.events.data.microsoft.com', 'eu-v20.events.data.microsoft.com', 'au.vortex-win.data.microsoft.com', 'au-v10.events.data.microsoft.com', 'au-v20.events.data.microsoft.com', 'uk.vortex-win.data.microsoft.com', 'uk-v20.events.data.microsoft.com', 'us-v10.events.data.microsoft.com', 'us-v20.events.data.microsoft.com', 'us4-v20.events.data.microsoft.com', 'us5-v20.events.data.microsoft.com', 'pipe.dev.trafficmanager.net', 'in-v10.events.data.microsoft.com', 'in-v20.events.data.microsoft.com', 'jp-v10.events.data.microsoft.com', 'jp-v20.events.data.microsoft.com', 'vortex.data.microsoft.com', 'dc.services.visualstudio.com', 'visualstudio-devdiv-c2s.msedge.net', 'az667904.vo.msecnd.net', 'scus-breeziest-in.cloudapp.net', 'nw-umwatson.events.data.microsoft.com', 'mobile.events.data.microsoft.com') }
            )
        }
        @{
            Id = 'priv.ifeo-telemetry-exes'
            Name = 'IFEO Debugger=taskkill for telemetry executables (CompatTelRunner, AggregatorHost, DeviceCensus, ...)'
            Risk = 'med'
            Phase = 10
            Source = 'RV'
            Note = 'CompatTelRunner also drives upgrade-compat scans.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\CompatTelRunner.exe'; Name = 'Debugger'; Kind = 'String'; Value = '%windir%\System32\taskkill.exe'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\AggregatorHost.exe'; Name = 'Debugger'; Kind = 'String'; Value = '%windir%\System32\taskkill.exe'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\DeviceCensus.exe'; Name = 'Debugger'; Kind = 'String'; Value = '%windir%\System32\taskkill.exe'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\FeatureLoader.exe'; Name = 'Debugger'; Kind = 'String'; Value = '%windir%\System32\taskkill.exe'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\BingChatInstaller.exe'; Name = 'Debugger'; Kind = 'String'; Value = '%windir%\System32\taskkill.exe'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\BGAUpsell.exe'; Name = 'Debugger'; Kind = 'String'; Value = '%windir%\System32\taskkill.exe'; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\BCILauncher.exe'; Name = 'Debugger'; Kind = 'String'; Value = '%windir%\System32\taskkill.exe'; TI = $true }
            )
        }
        @{
            Id = 'priv.advertising-id-off'
            Name = 'Advertising ID disabled (user, machine, policy; Id deleted)'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WH,WU'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; Name = 'Id'; Op = 'DeleteValue' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo'; Name = 'Id'; Op = 'DeleteValue' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo'; Name = 'DisabledByGroupPolicy'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo'; Name = 'DisabledByGroupPolicy'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\Store\AdvertisingInfo'; Name = 'Value'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'priv.tailored-diagnostics-feedback'
            Name = 'Tailored experiences, diagnostic transcript, feedback prompts (SIUF) off'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WH,WU'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy'; Name = 'TailoredExperiencesWithDiagnosticDataEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\DevicePolicy\TailoredExperiencesWithDiagnosticDataEnabled'; Name = 'DefaultValue'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey'; Name = 'EnableEventTranscript'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Siuf\Rules'; Name = 'NumberOfSIUFInPeriod'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Siuf\Rules'; Name = 'PeriodInNanoSeconds'; Op = 'DeleteValue' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'DoNotShowFeedbackNotifications'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name = 'DoNotShowFeedbackNotifications'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableTailoredExperiencesWithDiagnosticData'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name = 'DisableTailoredExperiencesWithDiagnosticData'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'priv.activity-history-off'
            Name = 'Activity history: feed, publish and upload user activities off'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WU'
            Note = 'EnableActivityFeed=0 (winutil sets 1, treated as a source bug).'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'UploadUserActivities'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'PublishUserActivities'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'EnableActivityFeed'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'PublishUserActivitiesOnUserConsent'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'priv.input-personalization-off'
            Name = 'Inking/typing/contact harvesting, TIPC, HttpAcceptLanguageOptOut off'
            Risk = 'low'
            Phase = 10
            Source = 'RV,RT,OD,WH,WU'
            Note = 'Registry part of the RT verb input-personalization disable; custom dictionary is not cleared.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\TextInput'; Name = 'AllowLinguisticDataCollection'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Input\TIPC'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Input\TIPC'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy'; Name = 'HasAccepted'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\Control Panel\International\User Profile'; Name = 'HttpAcceptLanguageOptOut'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\InputPersonalization'; Name = 'RestrictImplicitInkCollection'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\InputPersonalization'; Name = 'RestrictImplicitTextCollection'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore'; Name = 'HarvestContacts'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\InputPersonalization\Settings'; Name = 'AcceptedPrivacyPolicy'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\InputPersonalization'; Name = 'RestrictImplicitInkCollection'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\InputPersonalization'; Name = 'RestrictImplicitTextCollection'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization'; Name = 'RestrictImplicitInkCollection'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization'; Name = 'RestrictImplicitTextCollection'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization'; Name = 'AllowInputPersonalization'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Personalization\Settings'; Name = 'AcceptedPrivacyPolicy'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\Store\InkingAndTypingPersonalization'; Name = 'Value'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\Store\ImproveInkingAndTyping'; Name = 'Value'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'priv.online-speech-narrator'
            Name = 'Online speech recognition and Narrator cloud services/scripting off'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WH,WU'
            Note = 'Removes cloud dictation.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy'; Name = 'HasAccepted'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Narrator\NoRoam'; Name = 'OnlineServicesEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Narrator\NoRoam'; Name = 'ScriptingEnabled'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'priv.capability-consent-deny'
            Name = 'App capability ConsentStore=Deny (account info, calendar, tasks, chat, radios, diagnostics, libraries, filesystem)'
            Risk = 'med'
            Phase = 10
            Source = 'RV,WH'
            Note = 'Contacts/email/call history left alone. broadFileSystemAccess/library Deny can break some UWP apps.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\activity'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\activity'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
            )
        }
        @{
            Id = 'priv.location-sensors-off'
            Name = 'Location and sensors off (ConsentStore, LocationAndSensors policy, Maps auto-update, Geolocation)'
            Risk = 'med'
            Phase = 10
            Source = 'RV,OD,WH,WU'
            Note = 'Breaks auto-location in maps/weather. lfsvc service and Maps task are in svc/task groups.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location'; Name = 'Value'; Kind = 'String'; Value = 'Deny' }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'; Name = 'DisableLocation'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors'; Name = 'DisableSensors'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\Maps'; Name = 'AutoUpdateEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}'; Name = 'SensorPermissionState'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Geolocation'; Name = 'Status'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration'; Name = 'Status'; Kind = 'DWord'; Value = 0; TI = $true; RequireKey = $true }
            )
        }
        @{
            Id = 'priv.find-my-device-off'
            Name = 'Find My Device policy disabled'
            Risk = 'low'
            Phase = 10
            Source = 'OD'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice'; Name = 'AllowFindMyDevice'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'priv.wifi-sense-off'
            Name = 'Wi-Fi Sense / hotspot reporting and auto-connect to suggested hotspots off'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WH'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config'; Name = 'AutoConnectAllowedOEM'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features'; Name = 'PaidWifi'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\features'; Name = 'WiFiSenseOpen'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting'; Name = 'value'; Kind = 'DWord'; Value = 0; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowAutoConnectToWiFiSenseHotspots'; Name = 'value'; Kind = 'DWord'; Value = 0; TI = $true }
            )
        }
        @{
            Id = 'priv.settings-sync-off'
            Name = 'Windows Settings Sync categories disabled by policy (user override allowed)'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Note = 'Breaks cross-device sync of themes/passwords/language.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableApplicationSettingSync'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableApplicationSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableSettingSync'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableWebBrowserSettingSync'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableWebBrowserSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableDesktopThemeSettingSync'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableDesktopThemeSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableWindowsSettingSync'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableWindowsSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableCredentialsSettingSync'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableCredentialsSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisablePersonalizationSettingSync'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisablePersonalizationSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableStartLayoutSettingSync'; Kind = 'DWord'; Value = 2 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableStartLayoutSettingSyncUserOverride'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync'; Name = 'DisableSyncOnPaidNetwork'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'priv.cloud-messaging-misc'
            Name = 'Message cloud sync, EdgeUI help sticker, MFU tracking, NVIDIA control panel telemetry opt-out'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD'
            Note = 'NVIDIA key is written only if NVIDIA software created the parent key.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Messaging'; Name = 'AllowMessageSync'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI'; Name = 'DisableHelpSticker'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\EdgeUI'; Name = 'DisableMFUTracking'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\NVIDIA Corporation\NVControlPanel2\Client'; Name = 'OptInOrOutPreference'; Kind = 'DWord'; Value = 0; RequireKey = $true }
            )
        }
        @{
            Id = 'priv.feature-advert-tips'
            Name = 'Balloon feature adverts, online tips, cloud app notifications, Scoobe/finish-setup nags, suggestion toasts off'
            Risk = 'low'
            Phase = 10
            Source = 'RV,OD,WH,WU'
            Note = 'EnableAccountNotifications=0 (WH) rather than the 1 in RV: hides account nags. The SubscribedContent-* Settings suggestion values are in priv.content-delivery-off.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\Explorer'; Name = 'NoBalloonFeatureAdvertisements'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer'; Name = 'AllowOnlineTips'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications'; Name = 'NoCloudApplicationNotification'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement'; Name = 'ScoobeSystemSettingEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Context\CloudExperienceHostIntent\Wireless'; Name = 'ScoobeCheckCompleted'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications'; Name = 'EnableAccountNotifications'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.StartupApp'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Microsoft.SkyDrive.Desktop'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.AccountHealth'; Name = 'Enabled'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'priv.start-tracking-off'
            Name = 'Start menu tracking off (Start_TrackProgs/TrackDocs, recommendations, account notifications)'
            Risk = 'low'
            Phase = 10
            Source = 'OD,WH,WU'
            Note = 'May overlap the start group.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_TrackProgs'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_TrackDocs'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_IrisRecommendations'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'; Name = 'Start_AccountNotifications'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'priv.search-cloud-history'
            Name = 'Search device history, dynamic search box, MSA/AAD cloud search, Cortana policy off'
            Risk = 'low'
            Phase = 10
            Source = 'WH'
            Note = 'Bing-in-Start belongs to the start group.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings'; Name = 'IsDeviceSearchHistoryEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings'; Name = 'IsDynamicSearchBoxEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings'; Name = 'IsMSACloudSearchEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings'; Name = 'IsAADCloudSearchEnabled'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowCortana'; Kind = 'DWord'; Value = 0 }
                @{ Type = 'Registry'; Path = 'HKCU\SOFTWARE\Policies\Microsoft\Windows\Windows Search'; Name = 'AllowCortana'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'priv.mrt-reporting-off'
            Name = 'Malicious Software Removal Tool infection reporting off'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\MRT'; Name = 'DontReportInfectionInformation'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'priv.valuebanner-off'
            Name = 'Disable Settings value banner ads (ValueBanner ActivatableClassId)'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Note = 'TrustedInstaller key.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\ValueBanner.IdealStateFeatureControlProvider'; Name = 'ActivationType'; Kind = 'DWord'; Value = 4294967295; TI = $true }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\ValueBanner.IdealStateFeatureControlProvider'; Name = 'Server'; Kind = 'String'; Value = ''; TI = $true }
            )
        }
        @{
            Id = 'priv.dev-telemetry-env'
            Name = 'DOTNET_CLI_TELEMETRY_OPTOUT and POWERSHELL_TELEMETRY_OPTOUT machine env vars'
            Risk = 'low'
            Phase = 10
            Source = 'RV,WU'
            Note = 'Applies to new processes only.'
            Actions = @(
                @{ Type = 'Env'; Name = 'DOTNET_CLI_TELEMETRY_OPTOUT'; Value = '1'; Target = 'Machine' }
                @{ Type = 'Env'; Name = 'POWERSHELL_TELEMETRY_OPTOUT'; Value = '1'; Target = 'Machine' }
            )
        }
        @{
            Id = 'priv.winget-telemetry-off'
            Name = 'winget settings.json telemetry.disable for the default user and all existing profiles'
            Risk = 'low'
            Phase = 20
            Source = 'RV'
            Note = 'Merges into existing settings.json (backup kept as .windebloat.bak). Unparseable files are left alone.'
            Actions = @(
                @{ Type = 'Script'; Script = 'priv-WingetTelemetry' }
            )
        }
        @{
            Id = 'priv.office-telemetry-off'
            Name = 'Office ClickToRun log management/timer and all \Microsoft\Office\ scheduled tasks disabled'
            Risk = 'low'
            Phase = 20
            Source = 'RV'
            Note = 'Tasks directly under \Microsoft\Office\; N/A when Office is not installed.'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\ClickToRun\OverRide'; Name = 'DisableLogManagement'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration'; Name = 'TimerInterval'; Kind = 'String'; Value = '900000' }
                @{ Type = 'ScheduledTask'; Path = '\Microsoft\Office\'; Name = '*'; State = 'Disabled' }
            )
        }
        @{
            Id = 'priv.rsop-logging-off'
            Name = 'Resultant Set of Policy (RSoP) logging off'
            Risk = 'low'
            Phase = 10
            Source = 'RV'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\System'; Name = 'RSoPLogging'; Kind = 'DWord'; Value = 0 }
            )
        }
        @{
            Id = 'priv.usage-reporting-off'
            Name = 'Usage reporting off: DPS/diagsvc/WDI services, SleepStudy and power diagnostic logs'
            Risk = 'med'
            Phase = 20
            Source = 'RT'
            Note = 'DPS off hides some troubleshooters. Diagnostic channels use wevtutil sl /e:false (mech file lists /q:false, which does not change channel state).'
            Actions = @(
                @{ Type = 'Service'; Name = 'DPS'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'diagsvc'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'WdiServiceHost'; Start = 'Disabled' }
                @{ Type = 'Service'; Name = 'WdiSystemHost'; Start = 'Disabled' }
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power'; Name = 'SleepStudyDisabled'; Kind = 'DWord'; Value = 1; TI = $true }
                @{ Type = 'Exec'; Test = '$o = (wevtutil.exe gl Microsoft-Windows-SleepStudy/Diagnostic 2>&1 | Out-String); ($LASTEXITCODE -ne 0) -or ($o -match ''(?i)enabled:\s*false'')'; Apply = 'wevtutil.exe sl Microsoft-Windows-SleepStudy/Diagnostic /e:false' }
                @{ Type = 'Exec'; Test = '$o = (wevtutil.exe gl Microsoft-Windows-Kernel-Processor-Power/Diagnostic 2>&1 | Out-String); ($LASTEXITCODE -ne 0) -or ($o -match ''(?i)enabled:\s*false'')'; Apply = 'wevtutil.exe sl Microsoft-Windows-Kernel-Processor-Power/Diagnostic /e:false' }
                @{ Type = 'Exec'; Test = '$o = (wevtutil.exe gl Microsoft-Windows-UserModePowerService/Diagnostic 2>&1 | Out-String); ($LASTEXITCODE -ne 0) -or ($o -match ''(?i)enabled:\s*false'')'; Apply = 'wevtutil.exe sl Microsoft-Windows-UserModePowerService/Diagnostic /e:false' }
            )
        }
        @{
            Id = 'priv.device-metadata-network-off'
            Name = 'Prevent device metadata/companion apps download from the network'
            Risk = 'low'
            Phase = 10
            Source = 'RT,WU'
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata'; Name = 'PreventDeviceMetadataFromNetwork'; Kind = 'DWord'; Value = 1 }
                @{ Type = 'Registry'; Path = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata'; Name = 'PreventDeviceMetadataFromNetwork'; Kind = 'DWord'; Value = 1 }
            )
        }
        @{
            Id = 'priv.wpbt-off'
            Name = 'Disable Windows Platform Binary Table execution (OEM firmware-injected executables)'
            Risk = 'med'
            Phase = 10
            Source = 'WU'
            Note = 'May break OEM anti-theft/management tools injected via WPBT.'
            Reboot = $true
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager'; Name = 'DisableWpbtExecution'; Kind = 'DWord'; Value = 1 }
            )
        }
    )
}
