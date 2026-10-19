# group1 mech: Privacy & Telemetry, Security, Windows Update, Network & DNS, Misc

Conventions: DWORD unless noted. "(+DEFAULT)" = also write to `HKU\.DEFAULT` with same data (RV practice for HKCU). Inventories: P = playbook.md (RV), R = optimizerduck-revitool.md (RT/OD), W = winutil-regtweaks.md (WU), H = winhance.md (WH). Service start types and scheduled tasks are owned by the svc/task groups; cross-references only here. Items intentionally NOT here (other groups): Bing-in-Start, Game DVR, background apps (perf/game/start); Teredo/NetBT services (svc); Network throttling index (perf, RV keeps default 10); hosts file is item priv.hosts-telemetry-blocklist.

Windows Update approach conflict (read first): ReviOS originally set full WindowsUpdate policy keys, then `revert.yml` DELETES `HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate` (whole key) and relies on `revitool updates wu-pause-updates` (UX\Settings pause values, 2038). `NoAutoUpdate=1` is commented out (broke Xbox sign-in on old W10). Therefore upd.pause-2038 is the RV baseline; upd.policy-* items are alternatives, and any item writing under `Policies\...\WindowsUpdate` (upd.notification-level, upd.drivers-wu-off ExcludeWUDriversInQualityUpdate, upd.policy-security-only) is wiped if the revert-style key delete runs later. Our tool should NOT delete that key, or should apply those items after it.

## Privacy & Telemetry

### priv.telemetry-policy
Set AllowTelemetry=0 in all: `HKCU\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry`; `HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection\AllowTelemetry`; `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry`; `HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry`; `HKLM\SOFTWARE\Microsoft\PolicyManager\default\System\AllowTelemetry\value`; `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\DevicePolicy\AllowTelemetry\DefaultValue`; `...\CPSS\Store\AllowTelemetry\Value` (all 0). WH additionally sets `MaxTelemetryAllowed=0` (HKCU and HKLM `...\Policies\DataCollection`), `HKCU\...\Diagnostics\DiagTrack\ShowedToastAtLevel=1`, HKCU `...\Policies\DataCollection\AllowTelemetry=0`. RT/OD and WU set only the `CurrentVersion\Policies\DataCollection` + policy key. Services DiagTrack/dmwappushservice: see svc group. Build: 24H2/25H2 fine; Home/Pro treat 0 as Required (minimum). Revert: delete values.
src detail: playbook.md, optimizerduck-revitool.md, winutil-regtweaks.md, winhance.md (Privacy).

### priv.datacollection-hardening
`HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection`: AllowCommercialDataPipeline=0, AllowDeviceNameInTelemetry=0, DisableEnterpriseAuthProxy=1, MicrosoftEdgeDataOptIn=0, DisableTelemetryOptInChangeNotification=1, DisableTelemetryOptInSettingsUx=1, DoNotShowFeedbackNotifications=1, LimitEnhancedDiagnosticDataWindowsAnalytics=0, AllowBuildPreview=0, LimitDiagnosticLogCollection=1, LimitDumpCollection=1. Also `HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds\EnableConfigFlighting=0`; `HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\System\AllowExperimentation=0`. RT/OD subset: commercial pipeline, device name, Edge opt-in, feedback. Revert: delete values.
src detail: playbook.md, optimizerduck-revitool.md.

### priv.autologgers-off
`HKLM\SYSTEM\ControlSet001\Control\WMI\Autologger\<name>\Start=0`. RV: Diagtrack-Listener, SQMLogger, SetupPlatformTel. OD: AppModel, Cellcore, CloudExperienceHostOobe, DataMarket, DiagLog, Diagtrack-Listener, LwtNetLog, SQMLogger, WdiContextLog, WiFiSession (OD risk med; AppModel/Cellcore autologgers help ETW diagnostics, harmless to disable). Defender loggers DefenderApiLogger/DefenderAuditLogger default Start=1 (restore value). TrustedInstaller may be needed for some keys. Revert: Start=1 (default for most).
src detail: playbook.md, optimizerduck-revitool.md.

### priv.appcompat-policy
`HKLM\Software\Policies\Microsoft\Windows\AppCompat`: DisableEngine=1, AITEnable=0, DisableUAR=1, DisablePCA=1, DisableInventory=1, SbEnable=1 (RV, all). OD sets only DisableInventory=1, AITEnable=0; WH sets AITEnable=0 (HKCU+HKLM). DisableEngine=1 can stop legacy compat shims from applying (RV risk med); drop DisableEngine for a conservative variant. IFEO CompatTelRunner is separate (priv.ifeo-telemetry-exes). Revert: delete values.
src detail: playbook.md (app-compat.yml), optimizerduck-revitool.md, winhance.md.

### priv.ceip-off
`HKLM\Software\Policies\Microsoft\SQMClient\Windows\CEIPEnable=0`; `HKLM\SOFTWARE\Policies\Microsoft\AppV\CEIP\CEIPEnable=0`; `HKLM\Software\Policies\Microsoft\Internet Explorer\SQM\DisableCustomerImprovementProgram=1`; `HKLM\Software\Policies\Microsoft\Messenger\Client\CEIP=2`; `HKLM\Software\Microsoft\Windows NT\CurrentVersion\UnattendSettings\SQMClient\CEIPEnabled=0`. CEIP scheduled tasks: see task group. Revert: delete values.
src detail: playbook.md.

### priv.content-delivery-off
`HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager` (+DEFAULT) all =0: ContentDeliveryAllowed, SubscribedContentEnabled, SubscribedContent-{310093,338387,338388,338389,338393,353694,353696,314559,280815,314563,202914,280810,280811,353698}Enabled, SoftLandingEnabled, SilentInstalledAppsEnabled, PreInstalledAppsEnabled, PreInstalledAppsEverEnabled, OemPreInstalledAppsEnabled, FeatureManagementEnabled, RemediationRequired, RotatingLockScreenEnabled, RotatingLockScreenOverlayEnabled, SystemPaneSuggestionsEnabled. Delete subkeys `...\ContentDeliveryManager\Subscriptions` and `...\SuggestedApps` (RV only). OD subset: ContentDeliveryAllowed, 338387/338388/338389/353698, SystemPaneSuggestionsEnabled. WH has a master "Ads/Promotional" selector storing `HKCU\Software\Winhance\Settings\AdsPromotionalContentMode` (internal marker; ignore) that fans out to the same values. WH defaults (revert): most =1, null(delete) for SubscribedContent, PreInstalledAppsEverEnabled. Winhance note: turning off RotatingLockScreenEnabled sets Start recommended section to Show (ignore).
src detail: playbook.md, optimizerduck-revitool.md, winhance.md.

### priv.cloudcontent-policies
`HKLM\Software\Policies\Microsoft\Windows\CloudContent`: DisableSoftLanding=1, DisableTailoredExperiencesWithDiagnosticData=1, DisableCloudOptimizedContent=1 (RV, WU specialize), DisableConsumerAccountStateContent=1 (OD: stops Settings/Microsoft 365 account-state ads), DisableThirdPartySuggestions=1 (OD also). `HKCU\Software\Policies\Microsoft\Windows\CloudContent` (+DEFAULT; RV): ConfigureWindowsSpotlight=2, IncludeEnterpriseSpotlight=0, DisableThirdPartySuggestions=1, DisableTailoredExperiencesWithDiagnosticData=1, DisableWindowsSpotlightFeatures=1, DisableWindowsSpotlightWindowsWelcomeExperience=1, DisableWindowsSpotlightOnActionCenter=1, DisableWindowsSpotlightOnSettings=1. DO NOT set DisableWindowsConsumerFeatures (see priv.consumer-features-policy); RV `revert.yml` deletes it. Revert: delete values.
src detail: playbook.md, optimizerduck-revitool.md, winutil-regtweaks.md.

### priv.consumer-features-policy
`HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent\DisableWindowsConsumerFeatures=1` (OD, WU). ReviOS had it commented out then deletes it in revert.yml because it breaks Your Phone / Phone Link (and Store-promoted app features). Listed only to record the gotcha; not recommended. Revert: delete.
src detail: playbook.md, optimizerduck-revitool.md, winutil-regtweaks.md.

### priv.restrict-internet-comm
RV, under HKCU and HKLM `Software\Microsoft\Windows\CurrentVersion\Policies\Explorer`: NoPublishingWizard=1, NoWebServices=1, NoOnlinePrintsWizard=1, NoInternetOpenWith=1. HKLM: `...\Software Protection Platform\NoGenTicket=1`; `Policies\Microsoft\Windows NT\Printers`: DisableHTTPPrinting=1, DisableWebPnPDownload=1; `Policies\Microsoft\Windows\HandwritingErrorReports\PreventHandwritingErrorReports=1`; `Policies\Microsoft\Windows\TabletPC\PreventHandwritingDataSharing=1`; `Policies\Microsoft\PCHealth\HelpSvc`: Headlines=0, MicrosoftKBSearch=0; `PCHealth\ErrorReporting\DoReport=0`; `Policies\Microsoft\Windows\Internet Connection Wizard\ExitOnMSICW=1`; `Policies\Microsoft\EventViewer\MicrosoftEventVwrDisableLinks=1`; `Policies\Microsoft\Windows\Registration Wizard Control\NoRegistration=1`; `Policies\Microsoft\SearchCompanion\DisableContentFileUpdates=1`. HKCU `Policies\Microsoft\Assistance\Client\1.0`: NoOnlineAssist=1, NoExplicitFeedback=1, NoImplicitFeedback=1 (OD also sets HKLM NoActiveHelp=1); `Policies\Microsoft\WindowsMovieMaker`: WebHelp=1, CodecDownload=1, WebPublish=1. RV `revert.yml` also deletes the old "RestrictCommunication" key (do not write it). Revert: delete.
src detail: playbook.md, optimizerduck-revitool.md.

### priv.error-reporting-off
`HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting`: AutoApproveOSDumps=0, LoggingDisabled=1, Disabled=1, DontSendAdditionalData=1, DontShowUI=1; `HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Disabled=1`; `...\Windows Error Reporting\Consent`: DefaultConsent=0, DefaultOverrideBehavior=1; `Policies\...\Windows Error Reporting\Consent\0`="" (REG_SZ) (RV). WH also `HKCU\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting\Disabled=1` (WH default 0). RV finalize runs PS `Disable-WindowsErrorReporting`. HandwritingErrorReports covered in priv.restrict-internet-comm. Services WerSvc (RV), PcaSvc (OD) and WER tasks: svc/task groups. Revert: delete values / Disabled=0.
src detail: playbook.md, optimizerduck-revitool.md, winhance.md (Security section id security-error-reporting).

### priv.firewall-telemetry-block
Under BOTH `HKLM\SYSTEM\ControlSet001\Services\SharedAccess\Defaults\FirewallPolicy\FirewallRules` and `...\Parameters\FirewallPolicy\FirewallRules` write REG_SZ values: `Block-Unified-Telemetry-Client` = `v2.31|Action=Block|Active=TRUE|Dir=Out|RA42=IntErnet|RA62=IntErnet|App=%SystemRoot%\system32\svchost.exe|Svc=DiagTrack|Name=Block-Unified-Telemetry-Client|EmbedCtxt=DiagTrack|`; `Block-Windows-Error-Reporting` same with Svc=WerSvc. Intentionally excluded in RV: Block-Windows-Insider (wisvc) rule "breaks Xbox", and a Cortana hosts/firewall rule. No inventory source disables or reconfigures the firewall itself; leave Windows Firewall enabled. Revert: delete the two values.
src detail: playbook.md (privacy.yml).

### priv.hosts-telemetry-blocklist
Copy RV's `Executables\hosts` over `%WINDIR%\System32\drivers\etc\hosts`, then `ipconfig /flushdns`. ~50 entries -> 0.0.0.0: telemetry.microsoft.com, vortex-win.data.microsoft.com, watson.*.microsoft.com, *.events.data.microsoft.com, activity.windows.com, outlookads.live.com, dc.services.visualstudio.com, p3a.brave.com (+Brave p2a/cr/star-randsrv) etc. (full list in references\playbook\src hosts). Implementation tip: append a marked block instead of overwrite. Wildcards are not supported by hosts files (RV lists explicit names). Revert: restore backed-up hosts.
src detail: playbook.md (start.yml; also referenced under Network & DNS).

### priv.hosts-adobe-block
Download `https://github.com/Ruddernation-Designs/Adobe-URL-Block-List/raw/refs/heads/master/hosts`, append to hosts, `ipconfig /flushdns`. External list can block Adobe licensing/updates. Revert: remove appended block.
src detail: winutil-regtweaks.md (WPFTweaksBlockAdobeNet).

### priv.ifeo-telemetry-exes
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\<exe>\Debugger=%windir%\System32\taskkill.exe` (REG_SZ) for CompatTelRunner.exe, AggregatorHost.exe, DeviceCensus.exe, FeatureLoader.exe, BingChatInstaller.exe, BGAUpsell.exe, BCILauncher.exe. CompatTelRunner is also used by upgrade-compat scans. Windows Update/cumulative updates can recreate the exes but IFEO key persists (drift low; marked because tasks may re-register). Revert: delete the subkeys.
src detail: playbook.md (ifeo.yml).

### priv.advertising-id-off
`HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo\Enabled=0` (+DEFAULT); `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo\Enabled=0` (RV, OD); delete value `Id` (HKCU+HKLM, RV); `HKLM\Software\Policies\Microsoft\Windows\AdvertisingInfo\DisabledByGroupPolicy=1` (RV, OD, WH; WH also HKCU policy); WH also `HKCU\...\CPSS\Store\AdvertisingInfo\Value=0`. Revert: Enabled=1, delete policy.
src detail: playbook.md, optimizerduck-revitool.md, winhance.md, winutil-regtweaks.md.

### priv.tailored-diagnostics-feedback
`HKCU\Software\Microsoft\Windows\CurrentVersion\Privacy\TailoredExperiencesWithDiagnosticDataEnabled=0` (+DEFAULT); `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CPSS\DevicePolicy\TailoredExperiencesWithDiagnosticDataEnabled\DefaultValue=0`; `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack\EventTranscriptKey\EnableEventTranscript=0`; `HKCU\Software\Microsoft\Siuf\Rules\NumberOfSIUFInPeriod=0` (+DEFAULT) and delete `PeriodInNanoSeconds`; WH: DoNotShowFeedbackNotifications=1 (HKCU+HKLM policy DataCollection), WH tailored policy DisableTailoredExperiencesWithDiagnosticData=1 (HKCU+HKLM CloudContent). Revert: Tailored=1, delete rest.
src detail: playbook.md, optimizerduck-revitool.md, winhance.md, winutil-regtweaks.md.

### priv.activity-history-off
`HKLM\SOFTWARE\Policies\Microsoft\Windows\System`: UploadUserActivities=0, PublishUserActivities=0, EnableActivityFeed=0; OD also PublishUserActivitiesOnUserConsent=0. Note: winutil's source sets EnableActivityFeed=1 (inventory flags it "sic") - treat as a bug, use 0. Revert: delete values.
src detail: playbook.md, optimizerduck-revitool.md, winutil-regtweaks.md.

### priv.input-personalization-off
RV: `HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\TextInput\AllowLinguisticDataCollection=0`; `Software\Microsoft\Input\TIPC\Enabled=0` (HKCU+HKLM); `HKCU\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy\HasAccepted=0`; `revitool tweaks personalization input-personalization disable`; `HKCU\Control Panel\International\User Profile\HttpAcceptLanguageOptOut=1`. RT/OD verb writes: `HKCU\Software\Microsoft\InputPersonalization`: RestrictImplicitInkCollection=1, RestrictImplicitTextCollection=1, `TrainedDataStore\HarvestContacts=0`, `Settings\AcceptedPrivacyPolicy=0`; same Restrict* =1 under `HKCU\SOFTWARE\Policies\Microsoft\InputPersonalization` and `HKLM\...`; `HKLM\SOFTWARE\Policies\Microsoft\InputPersonalization\AllowInputPersonalization=0`. WH adds `HKCU\Software\Microsoft\Personalization\Settings\AcceptedPrivacyPolicy=0`, CPSS\Store\InkingAndTypingPersonalization\Value=0, CPSS\Store\ImproveInkingAndTyping\Value=0. RV's `revert.yml` lists InputPersonalization and ModelDownloadAllowed in its old-version rollback; RV still applies the TIPC/Linguistic ones. Revert: Restrict*=0, HarvestContacts=1, AllowInputPersonalization=1.
src detail: playbook.md, optimizerduck-revitool.md, winhance.md, winutil-regtweaks.md.

### priv.online-speech-narrator
`HKCU\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy\HasAccepted=0` (WH default 1); WH also AllowInputPersonalization policy removal when off. Narrator: `HKCU\Software\Microsoft\Narrator\NoRoam\OnlineServicesEnabled=0`, `ScriptingEnabled=0`. Revert: HasAccepted=1, delete Narrator values.
src detail: winhance.md, playbook.md.

### priv.capability-consent-deny
`HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\<cap>\Value` (REG_SZ) = Deny, and the HKLM equivalent, for caps: userAccountInformation, appointments, tasks(userDataTasks), chat, radios, bluetoothSync, appDiagnostics, documentsLibrary, picturesLibrary, videosLibrary, broadFileSystemAccess, activity(motion) (RV; HKCU+DEFAULT). WH only handles userAccountInformation and appDiagnostics (rec Deny, default Allow, HKLM). Contacts, phoneCallHistory, email, userNotificationListener intentionally untouched (Mail & Calendar needs Contacts). Location lives in priv.location-sensors-off; webcam/microphone in priv.camera-mic-access. broadFileSystemAccess/documents Deny can break some UWP apps. Revert: Allow.
src detail: playbook.md, winhance.md.

### priv.location-sensors-off
`...\ConsentStore\location\Value="Deny"` (HKCU+DEFAULT per RV; OD/WH/WU use HKLM, WH default "Allow"); `HKLM\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors`: DisableLocation=1, DisableSensors=1 (OD; WH also HKCU DisableLocation); `HKLM\SYSTEM\Maps\AutoUpdateEnabled=0`; `HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Permissions\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}\SensorPermissionState=0` (WU: `HKLM\...\Sensor\Overrides\{same}`); `HKCU\Software\Microsoft\Windows\CurrentVersion\Geolocation\Status=0`; `HKLM\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration\Status=0` (service lfsvc Disabled: svc group); task `\Microsoft\Windows\Maps\MapsUpdateTask` disabled (task group); OD also WiFi Sense PolicyManager values (see priv.wifi-sense-off). Revert: Allow / delete.
src detail: playbook.md, optimizerduck-revitool.md, winhance.md, winutil-regtweaks.md.

### priv.camera-mic-access
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\{webcam,microphone}\Value` (REG_SZ) Allow (RV and WH rec) or Deny (privacy option). Revert: Allow.
src detail: playbook.md, winhance.md.

### priv.find-my-device-off
`HKLM\SOFTWARE\Policies\Microsoft\FindMyDevice\AllowFindMyDevice=0`. Revert: delete.
src detail: optimizerduck-revitool.md.

### priv.wifi-sense-off
`HKLM\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config\AutoConnectAllowedOEM=0`; `...\wifinetworkmanager\features`: PaidWifi=0, WiFiSenseOpen=0 (RV); `HKLM\SOFTWARE\Microsoft\PolicyManager\default\WiFi\AllowWiFiHotSpotReporting\value=0` and `...\AllowAutoConnectToWiFiSenseHotspots\value=0` (RV, OD, WH). Revert: 1 / delete.
src detail: playbook.md, optimizerduck-revitool.md, winhance.md.

### priv.settings-sync-off
`HKLM\SOFTWARE\Policies\Microsoft\Windows\SettingSync`: Disable{ApplicationSettingSync,SettingSync,WebBrowserSettingSync,DesktopThemeSettingSync,WindowsSettingSync,CredentialsSettingSync,PersonalizationSettingSync,StartLayoutSettingSync}=2, each `<same>UserOverride=1`, DisableSyncOnPaidNetwork=1. Revert: delete key.
src detail: playbook.md.

### priv.cloud-messaging-misc
`HKLM\Software\Policies\Microsoft\Windows\Messaging\AllowMessageSync=0`; `HKLM\Software\Policies\Microsoft\Windows\EdgeUI\DisableHelpSticker=1`; `HKCU\Software\Policies\Microsoft\Windows\EdgeUI\DisableMFUTracking=1` (+DEFAULT); `HKCU\Software\NVIDIA Corporation\NVControlPanel2\Client\OptInOrOutPreference=0` (RV only; harmless if NVIDIA absent). Revert: delete.
src detail: playbook.md, optimizerduck-revitool.md.

### priv.feature-advert-tips
`HKCU\Software\Policies\Microsoft\Windows\Explorer\NoBalloonFeatureAdvertisements=1` (+DEFAULT); `HKLM\...\Policies\Explorer\AllowOnlineTips=0`; `HKLM\...\PushNotifications\NoCloudApplicationNotification=1`; `HKCU\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement\ScoobeSystemSettingEnabled=0`; `HKCU\...\CloudExperienceHostIntent\Wireless\ScoobeCheckCompleted=1`; `HKCU\...\SystemSettings\AccountNotifications\EnableAccountNotifications=1` (sic; RV) while WH sets it to 0 (they disagree: prefer WH 0 to hide account nags). WU: `HKCU\...\Notifications\Settings\{Windows.SystemToast.Suggested,Windows.SystemToast.StartupApp,Microsoft.SkyDrive.Desktop,Windows.SystemToast.AccountHealth}\Enabled=0`. WH: SubscribedContent-338393/353694/353696 (Settings suggestions), -310093 (welcome experience). Revert: delete/1.
src detail: playbook.md, winhance.md, winutil-regtweaks.md.

### priv.start-tracking-off
`HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced`: Start_TrackProgs=0 (OD, WH, WU), Start_TrackDocs=0, Start_IrisRecommendations=0, Start_AccountNotifications=0 (WU); WU also `HKCU\...\Start`: ShowFrequentList=0, ShowRecentList=0, ShowAllPinsList=0, AllAppsViewMode=2 (those layout ones belong to start group). Revert: 1.
src detail: optimizerduck-revitool.md, winhance.md, winutil-regtweaks.md.

### priv.search-cloud-history
`HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings`: IsDeviceSearchHistoryEnabled=0, IsDynamicSearchBoxEnabled=0, IsMSACloudSearchEnabled=0, IsAADCloudSearchEnabled=0; `Policies\Microsoft\Windows\Windows Search\AllowCortana=0` (HKLM+HKCU; Win10-era, harmless). Revert: delete (default on).
src detail: winhance.md.

### priv.mrt-reporting-off
`HKLM\Software\Policies\Microsoft\MRT\DontReportInfectionInformation=1`. Revert: delete.
src detail: playbook.md.

### priv.valuebanner-off
`HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\ValueBanner.IdealStateFeatureControlProvider`: ActivationType=4294967295 (0xFFFFFFFF), Server="" (REG_SZ). Needs TrustedInstaller. Revert: restore original (ActivationType=1, Server per backup).
src detail: playbook.md.

### priv.dev-telemetry-env
`setx DOTNET_CLI_TELEMETRY_OPTOUT 1 /M`, `setx POWERSHELL_TELEMETRY_OPTOUT 1 /M` (RV uses setx; WU sets machine env POWERSHELL_TELEMETRY_OPTOUT=1 only). Revert: delete env var.
src detail: playbook.md, winutil-regtweaks.md.

### priv.winget-telemetry-off
Write `{"telemetry":{"disable":true}}` to `%LOCALAPPDATA%\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json` for the default user template (`C:\Users\Default\AppData\Local\...`) and every existing profile (merge with existing JSON). Revert: remove key.
src detail: playbook.md (STARTMENU.cmd, settings.json).

### priv.office-telemetry-off
`HKLM\SOFTWARE\Microsoft\ClickToRun\OverRide\DisableLogManagement=1`; `HKLM\SOFTWARE\Microsoft\Office\ClickToRun\Configuration\TimerInterval=900000`; `Get-ScheduledTask -TaskPath "\Microsoft\Office\*" | Disable-ScheduledTask`. Revert: delete values, enable tasks.
src detail: playbook.md.

### priv.rsop-logging-off
`HKLM\SOFTWARE\Policies\Microsoft\Windows\System\RSoPLogging=0`. Revert: delete.
src detail: playbook.md.

### priv.usage-reporting-off
RT verb `tweaks utilities usage-reporting disable`: services DPS, diagsvc, WdiServiceHost, WdiSystemHost Start=4 under `HKLM\SYSTEM\ControlSet001\Services\<name>` (enable = Start=2; svc group may own these); `HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power\SleepStudyDisabled=1`; as TrustedInstaller: `wevtutil sl Microsoft-Windows-SleepStudy/Diagnostic /q:false`, same for `Microsoft-Windows-Kernel-Processor-Power/Diagnostic` and `Microsoft-Windows-UserModePowerService/Diagnostic`. Revert: delete SleepStudyDisabled, `/q:true`, Start=2.
src detail: optimizerduck-revitool.md.

### priv.device-metadata-network-off
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata\PreventDeviceMetadataFromNetwork=1` and `HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata\PreventDeviceMetadataFromNetwork=1` (WU: policy key only). Revert: delete.
src detail: winutil-regtweaks.md, optimizerduck-revitool.md.

### priv.wpbt-off
`HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DisableWpbtExecution=1`; reboot. May break OEM anti-theft/management injected via WPBT. Revert: delete.
src detail: winutil-regtweaks.md.

### priv.store-recommendations-block
`icacls "%LocalAppData%\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\store.db" /deny *S-1-1-0:F`. Locks Store DB. Revert: `icacls ... /remove:d *S-1-1-0`.
src detail: winutil-regtweaks.md.

### priv.telemetry-removal-package
`revitool winpackage --install telemetry-removal` (RV default-always): removes core telemetry WinSxS/CBS components. Needs Revision's signed CAB; internals unknown. Not reproducible without that package; use priv.telemetry-policy + svc items instead. Revert: `revitool winpackage --uninstall telemetry-removal`.
src detail: playbook.md, optimizerduck-revitool.md (CLI list).

### priv.oosu-external
Launch external O&O ShutUp10++ with a config. Not reproducible; redundant. Excluded in practice.
src detail: winutil-regtweaks.md.

## Security

### sec.defender-disable
Prerequisites: Tamper Protection must be OFF first (`HKLM\SOFTWARE\Microsoft\Windows Defender\Features\TamperProtection`, +TamperProtectionSource; cannot be set by script on 24H2 - user must toggle in Windows Security > Virus & threat protection settings, or the tool must open `windowsdefender://threatsettings` and wait/retry ~10x). Real-time protection also off (if Tamper off: `Set-MpPreference -DisableRealtimeMonitoring $true`). No third-party AV. Explorer must be running (RV kills explorer AFTER this step). Kill SecHealthUI.exe. ReviOS AME requirements: DefenderToggled, NoAntivirus.
revitool exact flow (RT `security defender disable [--force]`):
1. Write `HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\DisableAntiSpyware=1`, `DisableAntiVirus=1`, and `HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection\DisableRealtimeMonitoring=1`; run `gpupdate /Target:Computer /Force`; run `MpCmdRun.exe -RemoveDefinitions -All`.
2. As TrustedInstaller write `HKLM\SOFTWARE\Microsoft\Windows Defender\DisableAntiSpyware=1` and `DisableAntiVirus=1`; then repeat step 1's policy writes. JAN-2026 CAVEAT: after the Jan-2026 cumulative updates, `gpupdate` REMOVES the `Policies\...\Windows Defender\DisableAntiSpyware` value; the workaround (implemented by revitool) is to write the policy values, run gpupdate, write TI values, then re-write the policy values. Never run gpupdate after the last write; re-verify at the end and after reboot.
3. TI: `HKLM\System\ControlSet001\Services\MDCoreSvc\Start=4`; delete RunOnce value `RevisionEnableDefenderCMD`.
4. (Package step, separate item) install CBS package `Revision-ReviOS-Defender-Removal` - see sec.defender-remove-package. Without it, services/drivers remain (WinDefend, WdFilter, WdBoot, Sense, etc.) but disabled by policy; Start=4 on them can be done as an extra (see svc group) after tamper is off.
Status detection: considered disabled if package installed OR DisableAntiSpyware=1 OR WinDefend Start=4.
Companion items: sec.defender-ui-hide, sec.smartscreen-off, sec.vbs-off.
Revert (RT `defender enable`, exact original state): delete policy values DisableAntiSpyware/DisableAntiVirus/DisableRealtimeMonitoring (Policies and core keys); uninstall defender-removal package; gpupdate; `MDCoreSvc\Start=2`; RunOnce `RevisionEnableDefenderCMD`=`"<MpCmdRun.exe path>" -WDEnable`; delete `HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray\HideSystray`; `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth`=`%windir%\system32\SecurityHealthSystray.exe`; service Start under `HKLM\SYSTEM\ControlSet001\Services\`: MsSecCore=0, MsSecFlt=0, MsSecWfp=3, SecurityHealthService=3, Sense=3, WdBoot=0, WdFilter=0, WdNisDrv=3, WdNisSvc=3, WinDefend=2, wscsvc=2, MDCoreSvc=2, SgrmAgent=0, SgrmBroker=2, webthreatdefsvc=3, webthreatdefusersvc=2 (+ per-user `webthreatdefusersvc_*`=2); delete IFEO `...\Image File Execution Options\smartscreen.exe`; rename `C:\Windows\System32\smartscreen.exe.revi` back to `smartscreen.exe`; delete `HKCU\...\Policies\Associations`; `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SmartScreenEnabled`="On"; delete `HKLM\Software\Policies\Microsoft\System\EnableSmartScreen`, AppHost `EnableWebContentEvaluation`/`PreventOverride`, `HKLM\SYSTEM\ControlSet001\Control\CI\Policy\VerifiedAndReputablePolicyState`; delete keys `HKLM\Software\Policies\Microsoft\Windows Defender`, `...\Windows Advanced Threat Protection`, `...\Windows Defender Security Center`; `HKLM\SOFTWARE\Microsoft\Windows Defender\PUAProtection=1`; delete `HKLM\SYSTEM\ControlSet001\Control\CI\Config\VulnerableDriverBlocklistEnable` and `...\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity\Enabled`; `...\Control\WMI\Autologger\DefenderApiLogger\Start=1`, `DefenderAuditLogger\Start=1`.
Build: 24H2/25H2 supported by RT; Defender updates/platform updates may re-enable (drift) - re-check after cumulative updates. RV also reverts and re-adds `Windows Defender\Signature Updates` key (see sec.defender-reporting).
src detail: optimizerduck-revitool.md (Security: Defender DISABLE/ENABLE), playbook.md (Security, Ordering notes).

### sec.defender-remove-package
`revitool winpackage --install defender-removal` / CBS package `Revision-ReviOS-Defender-Removal` (RT step 4 of sec.defender-disable) "does the rest": removes Defender components from the component store. It is a Revision-signed CAB served by their tooling; contents are opaque and cannot be reproduced or substituted without the CAB. Marked ⛔ (not reproducible); sec.defender-disable (policy + MDCoreSvc + service Start=4) is the achievable version. Revert: `revitool winpackage --uninstall defender-removal`.
src detail: optimizerduck-revitool.md, playbook.md.

### sec.defender-ui-hide
`HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\Systray\HideSystray=1`; delete `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run\SecurityHealth` (RV). WH (opposite toggle "Windows Security Notifications"): set DisableNotifications=1 and DisableEnhancedNotifications=1 under `HKLM\Software\Microsoft\Windows Defender Security Center\Notifications`, `HKCU\Software\Policies\...\Notifications`, `HKLM\Software\Policies\...\Notifications` to hide toasts (WH default: absent). RV also `HKCU\Software\Microsoft\Windows Security Health\State\AccountProtection_MicrosoftAccount_Disconnected=0` (silences account-protection nag). Revert: delete / restore Run value `SecurityHealthSystray.exe`.
src detail: playbook.md, winhance.md.

### sec.defender-reporting
`HKLM\Software\Policies\Microsoft\Windows Defender\Reporting\DisableGenericRePorts=1`; `...\Windows Defender\Spynet\SubmitSamplesConsent=2` (RV; WU runs `Set-MpPreference -SubmitSamplesConsent 2`); RV after revert deletes `...\Windows Defender\Signature Updates` key then re-adds `DisableScheduledSignatureUpdateOnBattery=1`. Revert: delete values.
src detail: playbook.md, winutil-regtweaks.md.

### sec.smartscreen-off
RV: `HKLM\Software\Policies\Microsoft\Windows Defender\SmartScreen`: ConfigureAppInstallControlEnabled=1, ConfigureAppInstallControl="Anywhere" (REG_SZ); `HKCU\Software\Microsoft\Windows\CurrentVersion\AppHost\EnableWebContentEvaluation=0` (+DEFAULT); `HKLM\Software\Policies\Microsoft\MicrosoftEdge\PhishingFilter\EnabledV9=0`. RT (inside Defender disable): also `HKLM\Software\Policies\Microsoft\System\EnableSmartScreen=0`, `HKLM\...\Explorer\SmartScreenEnabled="Off"`, IFEO `smartscreen.exe` Debugger, rename `smartscreen.exe` -> `smartscreen.exe.revi` (needs TI), `HKLM\SYSTEM\ControlSet001\Control\CI\Policy\VerifiedAndReputablePolicyState`; enable path listed in sec.defender-disable. Edge SmartScreen/WebView policies also covered in edge group. Revert: delete values.
src detail: playbook.md, optimizerduck-revitool.md.

### sec.smart-app-control-off
`HKLM\SYSTEM\CurrentControlSet\Control\CI\Policy\VerifiedAndReputablePolicyState` = 0 (Off), 1 (On), 2 (Evaluation; WH default). Once off it cannot be turned back on without reset/reinstall (OS behaviour). Requires reboot. Revert: not possible in-place (Windows limitation).
src detail: winhance.md.

### sec.vbs-off
RT `security vbs disable`: `bcdedit /set vsmlaunchtype off`; `HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard`: EnableVirtualizationBasedSecurity=0, LsaCfgFlags=0, HVCIMATRequired=0; `HKLM\SYSTEM\ControlSet001\Control\DeviceGuard`: EnableVirtualizationBasedSecurity=0, Mandatory=0, HVCIMATRequired=0; also runs memory-integrity disable (sec.hvci-off). WH variant: `HKLM\SYSTEM\CurrentControlSet\Control\DeviceGuard`: EnableVirtualizationBasedSecurity=0, RequirePlatformSecurityFeatures=0, Locked=0. If VBS is UEFI-locked, registry alone is insufficient (needs manual UEFI/Windows Security change). RV applies always (revitool verb). Revert (RT enable): `bcdedit /deletevalue hypervisorlaunchtype` and `vsmlaunchtype`; EnableVirtualizationBasedSecurity=1 in both places; delete Mandatory, HVCIMATRequired.
src detail: playbook.md (Security, Gaming), optimizerduck-revitool.md, winhance.md.

### sec.hvci-off
`HKLM\SYSTEM\ControlSet001\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity\Enabled=0`; delete `WasEnabledBy` and `ChangedInBootCycle` (RT). WH writes Enabled=0, Locked=0, WasEnabledBy=0 (default 2). Gotcha: RV does NOT set `HKLM\SYSTEM\CurrentControlSet\Control\CI\Config\VulnerableDriverBlocklistEnable=0` (reverted: breaks THE FINALS). Revert: Enabled=1 / delete.
src detail: optimizerduck-revitool.md, winhance.md, playbook.md.

### sec.cpu-mitigations-off
`HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management`: FeatureSettings=1; FeatureSettingsOverride |= 0x3 (Meltdown/Spectre) and/or 0x02000000 (Downfall); FeatureSettingsOverrideMask = same bits. Re-enable: delete FeatureSettings->0 and Override/Mask values. RV's revert.yml removes its older FeatureSettings* / mitigation keys, i.e. ReviOS abandoned this. Large security regression; performance gain small on modern CPUs.
src detail: optimizerduck-revitool.md, playbook.md (revert.yml).

### sec.uac-off
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System`. RT disable: EnableVirtualization=0, EnableInstallerDetection=0, PromptOnSecureDesktop=0, EnableLUA=0, EnableSecureUIAPaths=0, ConsentPromptBehaviorAdmin=0, ValidateAdminCodeSignatures=0, EnableUIADesktopToggle=0, ConsentPromptBehaviorUser=0, FilterAdministratorToken=0. RT enable: first five =1, ConsentPromptBehaviorAdmin=5, ConsentPromptBehaviorUser=3, rest 0. WH levels: ConsentPromptBehaviorAdmin/PromptOnSecureDesktop = Prompt creds 1/1, Always notify 2/1, Default 5/1, No-dim 5/0, Never 0/0 (WH marks Never notify as REC but keeps EnableLUA). Safer alternative: ConsentPromptBehaviorAdmin=0 with EnableLUA=1. EnableLUA=0 needs reboot and breaks Store/UWP apps, Edge sandbox expectations.
src detail: optimizerduck-revitool.md, winhance.md.

### sec.autoplay-off
`HKCU` and `HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoDriveTypeAutoRun=255`; `HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers\DisableAutoplay=1` (+DEFAULT). Revert: delete (WH default absent).
src detail: playbook.md, winhance.md (Misc).

### sec.show-file-extensions
`HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt=0` (+DEFAULT). RV rationale: security. Revert: 1.
src detail: playbook.md.

### sec.linked-connections
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\EnableLinkedConnections=1`. Reboot. Revert: delete.
src detail: playbook.md.

### sec.bitlocker-auto-encrypt-off
`HKLM\SYSTEM\CurrentControlSet\Control\BitLocker\PreventDeviceEncryption=1` (WH default 0; WH is Windows-11-only toggle). RV's bitlocker.yml is NOT included from registry.yml (dead); RV only covers ISO builds via playbook.conf DisableBitLocker. No effect if encryption already active. Revert: 0.
src detail: playbook.md, winutil-regtweaks.md, winhance.md.

### sec.bitlocker-decrypt
`Disable-BitLocker -MountPoint $Env:SystemDrive` (run only if ProtectionStatus=On). Decryption takes time. Revert: re-enable BitLocker (manual).
src detail: winutil-regtweaks.md.

### sec.password-never-expires
`net accounts /maxpwage:unlimited`. Revert: `net accounts /maxpwage:42`.
src detail: playbook.md, winutil-regtweaks.md.

### sec.refresh-root-certs
`CertUtil -generateSSTFromWU <sst>` then Import-Certificate into `Cert:\LocalMachine\Root` and `Cert:\LocalMachine\AuthRoot` (RT `updates certificates` action). Related RV gotcha: delete `HKLM\SOFTWARE\Policies\Microsoft\SystemCertificates\AuthRoot\DisableRootAutoUpdate` (needed by MS Store) - do not set it. Revert: n/a (one-shot).
src detail: optimizerduck-revitool.md, playbook.md.

### sec.workplace-join-prompts-off
`BlockAADWorkplaceJoin=1` under `HKLM\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin` and `HKCU\SOFTWARE\Policies\Microsoft\Windows\WorkplaceJoin`. Revert: delete.
src detail: winhance.md.

### sec.remote-assistance-off
`HKLM\SYSTEM\CurrentControlSet\Control\Remote Assistance\fAllowToGetHelp=0` (WH default 1). Revert: 1.
src detail: winhance.md.

### sec.ps-execution-policy
`HKCU` and `HKLM\Software\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell\ExecutionPolicy` (REG_SZ) = RemoteSigned (WH rec); options Restricted(default)/AllSigned/RemoteSigned/Unrestricted/Bypass. Prefer `Set-ExecutionPolicy -Scope LocalMachine`. Revert: Restricted.
src detail: winhance.md.

### sec.rdp-unsigned-warning-off
`HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client\RedirectionWarningDialogVersion=1`; `HKCU\SOFTWARE\Microsoft\Terminal Server Client\RdpLaunchConsentAccepted=1`. Lowers RDP-file phishing protection. Revert: delete.
src detail: winutil-regtweaks.md.

## Windows Update

### upd.pause-2038
RT `tweaks updates wu-pause-updates enable`: `HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings`: FlightSettingsMaxPauseDays=5269; PauseFeatureUpdatesStartTime, PauseQualityUpdatesStartTime, PauseUpdatesStartTime = "2023-08-17T12:47:51Z" (REG_SZ); PauseFeatureUpdatesEndTime, PauseQualityUpdatesEndTime, PauseUpdatesExpiryTime = "2038-01-19T03:14:07Z" (REG_SZ). OD alone: FlightSettingsMaxPauseDays=0xFFFFFFFF (cap raise only). WH Paused mode: Pause*Time 2025-01-01T00:00:00Z..2051-12-31T00:00:00Z, FlightSettingsMaxPauseDays=10023, plus policy values (see upd.policy-*). Use a start time close to "now" and end 2038 for sanity. Disable = delete all 7 values. Windows can reset these on feature update/Settings use (drift). Services wuauserv/UsoSvc/WaaSMedicSvc left Manual (OD profile; svc group). WU scheduled tasks: task group.
Conflict note: this replaces ReviOS's earlier full-policy approach (see header).
src detail: playbook.md, optimizerduck-revitool.md, winhance.md.

### upd.policy-security-only
WH "Security Updates Only" (REC in WH): `HKLM+HKCU SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\AUOptions=2`; `HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings`: BranchReadinessLevel=20, DeferFeatureUpdates=1, DeferFeatureUpdatesPeriodInDays=365, DeferQualityUpdates=1, DeferQualityUpdatesPeriodInDays=7. "Normal" = remove all of these plus NoAutoUpdate, UseWUServer, NoAUShutdownOption, AlwaysAutoRebootAtScheduledTime, AutoInstallMinorUpdates, Pause* values, PausedQualityDate, PausedFeatureDate, PausedFeatureStatus, PausedQualityStatus, FlightSettingsMaxPauseDays. Alternative to upd.pause-2038; do not combine (policy key gets wiped by the RV-style revert).
src detail: winhance.md.

### upd.policy-disabled
WH Disabled: `...\Policies\Microsoft\Windows\WindowsUpdate\AU`: NoAutoUpdate=1, AUOptions=1, UseWUServer=0 (HKLM+HKCU); WH also NoAUShutdownOption=1, AlwaysAutoRebootAtScheduledTime=0, AutoInstallMinorUpdates=0, PausedFeatureStatus=1, PausedQualityStatus=1. Services wuauserv, UsoSvc, WaaSMedicSvc -> Disabled(4); disable tasks under \Microsoft\Windows\InstallService\, \UpdateOrchestrator\, \UpdateAssistant\, \WaaSMedic\, \WindowsUpdate\; takeown + icacls `*S-1-1-0:F`, rename `C:\Windows\System32\WaaSMedicSvc.dll` and `wuaueng.dll` to `*_BAK.dll`; `Remove-Item C:\Windows\SoftwareDistribution\*`. WU variant (setup-phase only, then reverted by WU): `...\WindowsUpdate\AU\NoAutoUpdate=1`, `...\WindowsUpdate\DisableWindowsUpdateAccess=1`. WU restore recipe: BITS=Manual, wuauserv=Manual, UsoSvc=Auto, WaaSMedicSvc Start=3; delete NoAutoUpdate, AUOptions, UseWUServer, DisableWindowsUpdateAccess, WUServer, WUStatusServer; delete DeliveryOptimization\Config\DODownloadMode. Gotcha: NoAutoUpdate=1 broke Xbox sign-in (RV comment); DLL renames break servicing, Store, and Defender definitions.
src detail: winhance.md, winutil-regtweaks.md, playbook.md.

### upd.drivers-wu-off
RT `tweaks updates wu-drivers disable`: `HKCU\Software\Policies\Microsoft\Windows\DriverSearching`: DontSearchWindowsUpdate=1, DriverUpdateWizardWuSearchEnabled=0, DontPromptForWindowsUpdate=1; HKLM `...\DriverSearching`: DontPromptForWindowsUpdate=1, SearchOrderConfig=0; `HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\ExcludeWUDriversInQualityUpdate=1` and `HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings\ExcludeWUDriversInQualityUpdate=1`; `PreventDeviceMetadataFromNetwork=1` at `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata` and `HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata`. RV equivalence stated as `HKLM\Software\Policies\Microsoft\Windows\DriverSearching\DontSearchWindowsUpdate=1`. WH: ExcludeWUDriversInQualityUpdate=1 under HKCU+HKLM `...\Policies\...\WindowsUpdate` only. Enable = delete those. Note: policy-key writes are wiped if a revert-style key delete runs. Drivers still installable manually/OEM.
src detail: playbook.md, optimizerduck-revitool.md, winhance.md.

### upd.notification-level
`HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\UpdateNotificationLevel=2` (RV; no notices incl. restart warnings). WH writes `SetUpdateNotificationLevel=2` (HKCU+HKLM, same key) - value name differs between sources; the documented policy is `SetUpdateNotificationLevel` (use that; RV's name may be ineffective). RV's revert.yml deletes the whole key afterward, so in RV this is effectively inert. Revert: delete.
src detail: playbook.md, winhance.md.

### upd.hide-upgrade-mct
`HKLM\SYSTEM\Setup\UpgradeNotification\UpgradeAvailable=0`; `HKLM\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings`: HideMCTLink=1, RestartNotificationsAllowed2=0. Revert: delete / 1.
src detail: playbook.md.

### upd.delivery-optimization-off
`HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization\DODownloadMode=0` (RV, OD, WU; HTTP-only, no peer sharing). WH options (HKCU+HKLM same key): default delete, 1 LAN only, 3 LAN+Internet, 99 "Disabled" (bypass; WH REC). Service DoSvc: svc group. WU's restore recipe deletes `...DeliveryOptimization\Config\DODownloadMode`. Revert: delete.
src detail: playbook.md, optimizerduck-revitool.md, winutil-regtweaks.md, winhance.md.

### upd.insider-off
`HKLM\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds\AllowBuildPreview=0` (also under DataCollection) and EnableConfigFlighting=0; hide Insider page via `revitool registry hide-page` (SettingsPageVisibility `windowsinsider`). Revert: delete.
src detail: playbook.md.

### upd.store-autodownload-off
`HKLM\Software\Policies\Microsoft\WindowsStore`: AutoDownload=4 (off), DisableOSUpgrade=1 (RV). WH toggles AutoDownload (HKCU+HKLM): on=4(auto download off), rec=2 -> WH recommends leaving Store updates enabled (value 2 = always on?) meaning WH disagrees with RV. Revert: delete.
src detail: playbook.md, winhance.md.

### upd.wmp-autoupdate-off
`HKLM\Software\Policies\Microsoft\WindowsMediaPlayer\DisableAutoUpdate=1`. Revert: delete.
src detail: playbook.md.

### upd.register-au-off
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Services\Pending\7971f918-a847-4430-9279-4a52d1efe18d\RegisterWithAU=0`. Revert: delete.
src detail: playbook.md.

### upd.hw-requirements-bypass
Runtime-useful parts: `HKLM\SYSTEM\Setup\MoSetup\AllowUpgradesWithUnsupportedTPMOrCPU=1`; `HKCU\Control Panel\UnsupportedHardwareNotificationCache\SV1=0`, `SV2=0`. Install-time `HKLM\SYSTEM\Setup\LabConfig` Bypass{SecureBoot,TPM,CPU,RAM,Storage}Check=1 only matters during Setup (excluded as install-time; include only for in-place upgrade media). Revert: delete.
src detail: playbook.md, winutil-regtweaks.md.

### upd.hide-wu-page
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\SettingsPageVisibility` (REG_SZ) = `hide:...;windowsupdate;` (append, RT `updates wu-visibility` / `registry hide-page --value windowsupdate`). Shared value with misc.hide-settings-pages: always merge, never overwrite. Revert: remove token.
src detail: optimizerduck-revitool.md.

### upd.restart-behavior
WH: `HKLM+HKCU SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\NoAutoRebootWithLoggedOnUsers=1` (off = delete); `HKLM\Software\Microsoft\WindowsUpdate\UX\Settings`: IsExpedited=0 ("Get me up to date", default 1), RestartNotificationsAllowed2 (RV 0, WH pref default 0). RV gotcha: `DisableAutomaticRestartSignOn` caused slow Hello logon (reverted) - do not set. Revert: delete / defaults.
src detail: winhance.md, playbook.md.

### upd.wu-ux-prefs
`HKLM\Software\Microsoft\WindowsUpdate\UX\Settings`: AllowMUUpdateService (other MS products; default 0), AllowAutoWindowsUpdateDownloadOverMeteredNetwork (default 1), IsContinuousInnovationOptedIn (get latest updates ASAP; WH rec 0). Revert: defaults.
src detail: winhance.md.

### upd.vendor-driver-software-block
WH: `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer\DisableCoInstallers=1`. WU Razer: also `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching\SearchOrderConfig=0`, empty folder `%SystemRoot%\Installer\Razer` and `icacls /deny *S-1-1-0:(W)`. WU Logitech: kill `logi_download_assistant`, empty and deny-write ACL `%ProgramW6432%\LogiDownloadAssistant`. Co-installers off prevents vendor companion software; some drivers lose control panels. Revert: delete values, remove deny ACLs.
src detail: winhance.md, winutil-regtweaks.md.

### upd.tasks-and-health-tools
Cross-reference only: WU tasks (`\Microsoft\Windows\WindowsUpdate\Scheduled Start`, UpdateOrchestrator) live in the Scheduled Tasks group; Update Health Tools / rempl / CloudManagedUpdate removal in Features group (RV FINALIZE.cmd). Other WU items RV reverted: `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Servicing\RepairContentServerSource` deleted (restores Features-on-Demand fetch from WU), ConnectedSearchSafeSearch, WU Servicing policies. Do not re-create them. Drift: tasks/health tools are reinstalled by CU.
src detail: playbook.md.

## Network & DNS

### net.dns-provider
Apply to every adapter: `Get-NetAdapter | ForEach-Object { Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses @('<v4 primary>','<v4 secondary>', <v6...>) }`. Revert: `-ResetServerAddresses`. winutil providers (IPv4 / IPv6):
- Google: 8.8.8.8, 8.8.4.4 / 2001:4860:4860::8888, 2001:4860:4860::8844
- Cloudflare: 1.1.1.1, 1.0.0.1 / 2606:4700:4700::1111, ::1001
- Cloudflare_Malware: 1.1.1.2, 1.0.0.2 / 2606:4700:4700::1112, ::1002
- Cloudflare_Malware_Adult: 1.1.1.3, 1.0.0.3 / 2606:4700:4700::1113, ::1003
- Open_DNS: 208.67.222.222, 208.67.220.220 / 2620:119:35::35, 2620:119:53::53
- Quad9: 9.9.9.9, 149.112.112.112 / 2620:fe::fe, 2620:fe::9
- AdGuard_Ads_Trackers: 94.140.14.14, 94.140.15.15 / 2a10:50c0::ad1:ff, ::ad2:ff
- AdGuard_Ads_Trackers_Malware_Adult: 94.140.14.15, 94.140.15.16 / 2a10:50c0::bad1:ff, ::bad2:ff
WH offers Automatic (default, REC), Cloudflare, Cloudflare malware, Cloudflare malware+adult, Google, Quad9, OpenDNS (IPv4 only; no AdGuard). ReviOS applies no DNS changes. CLI should let user pick provider; default = leave DHCP.
src detail: winutil-regtweaks.md (Network & DNS), winhance.md (DNS Server, notes).

### net.dns-over-https
Per server IP: `netsh dns add encryption server=<ip> dohtemplate=<url> autoupgrade=yes udpfallback=no`; first delete any old entries `netsh dns delete encryption server=<ip>` for known IPs. Templates: Google https://dns.google/dns-query; Cloudflare https://cloudflare-dns.com/dns-query; Cloudflare malware https://security.cloudflare-dns.com/dns-query; Cloudflare family https://family.cloudflare-dns.com/dns-query; OpenDNS https://doh.opendns.com/dns-query; Quad9 https://dns.quad9.net/dns-query; AdGuard https://dns.adguard-dns.com/dns-query; AdGuard family https://family.adguard-dns.com/dns-query. Requires net.dns-provider with matching IPs. Windows 11 supports DoH natively (build 22000+). Revert: `netsh dns delete encryption server=<ip>`.
src detail: winutil-regtweaks.md, winhance.md (DNS notes: options 7-9).

### net.smart-name-resolution-off
`HKLM\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient\DisableSmartNameResolution=1` (stops queries on all adapters). Revert: delete.
src detail: optimizerduck-revitool.md.

### net.ipv4-preferred
`HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\DisabledComponents=32`. Revert: delete (0). Same value used by net.teredo-disable (1) and net.ipv6-disable (255): last writer wins.
src detail: winutil-regtweaks.md.

### net.ipv6-disable
`DisabledComponents=255` (same key as above); `Disable-NetAdapterBinding -Name * -ComponentID ms_tcpip6`. Revert: delete value and `Enable-NetAdapterBinding`.
src detail: winutil-regtweaks.md.

### net.teredo-disable
WU: `DisabledComponents=1` (same Tcpip6 key) and `netsh interface teredo set state disabled`. RV instead: `netsh interface Teredo set state type=default` and `netsh interface Teredo set state servername=default` (resets). Conflict: choose disable (WU) or default (RV baseline). NetBT: svc group.
src detail: winutil-regtweaks.md, playbook.md.

### net.nagle-off
For each adapter GUID under `HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\<guid>`: TcpAckFrequency=1, TCPNoDelay=1. Revert: delete both. Per-adapter; new adapters not covered.
src detail: winhance.md.

### net.bbr2-congestion
`netsh int tcp set supplemental internet congestionprovider=default` was ReviOS's revert of BBR2 (breaks websockets, issue #27). Do not set `congestionprovider=bbr2`. Recorded as a gotcha only.
src detail: playbook.md (revert.yml).

### net.ntp-pool
`w32tm /config /manualpeerlist:"pool.ntp.org" /syncfromflags:manual /update` (replaces time.windows.com), then `w32tm /resync`; service W32Time must run. Revert: `/manualpeerlist:time.windows.com`.
src detail: winutil-regtweaks.md.

## Misc

### misc.utc-hardware-clock
`HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\RealTimeIsUniversal=1` (DWORD). Windows-only machines show wrong time until resync. Revert: delete.
src detail: playbook.md, optimizerduck-revitool.md.

### misc.boot-menu-legacy
`bcdedit /set {current} bootmenupolicy Legacy`; `bcdedit /set {current} lastknowngood yes`. Revert: `bootmenupolicy Standard`, `lastknowngood no`.
src detail: playbook.md (FINALIZE.cmd).

### misc.classic-photo-viewer
Register PhotoViewer.dll as handler (~90 values): `HKCR\PhotoViewer.FileAssoc.{Bitmap,JFIF,Jpeg,Gif,Png,Wdp,Tiff}` (shell\open\command with rundll32 PhotoViewer.dll,ImageView_Fullscreen), `HKCR\Applications\photoviewer.dll`, `HKLM\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities` (+FileAssociations for .jpg .jpeg .png .gif .bmp .tif .tiff .ico .jfif .dib .jpe .jxr .wdp), `HKCU` / `HKU\S-1-5-18\Software\Classes\.<ext>` default = PhotoViewer.FileAssoc.Tiff or Wdp, `HKCR\SystemFileAssociations\image\shell\Image Preview`. RV applies only with option remove-appx-photos. Requires file-assoc reset; 24H2 may need user choice (UserChoice hash) for defaults. Revert: delete keys.
src detail: playbook.md (classic-photo-viewer.yml).

### misc.developer-mode
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\AllowDevelopmentWithoutDevLicense=1`. Revert: 0.
src detail: optimizerduck-revitool.md, winhance.md.

### misc.sideload-trusted-apps
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\AllowAllTrustedApps=1`. Revert: 0.
src detail: optimizerduck-revitool.md.

### misc.long-paths
`HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled=1`. Revert: 0.
src detail: optimizerduck-revitool.md.

### misc.numlock-boot
Set bit 2 of `InitialKeyboardIndicators` (REG_SZ; value "2"/"2147483650" style, OR with existing) in `HKCU\Control Panel\Keyboard` and `HKU\.DEFAULT\Control Panel\Keyboard`. Fast Startup can override the logon-screen state. Revert: restore prior value.
src detail: optimizerduck-revitool.md.


### misc.restore-point
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore\SystemRestorePointCreationFrequency=0` (temporarily, to bypass 24h throttle; OD restores previous); `Enable-ComputerRestore -Drive "C:\"`; `Checkpoint-Computer -Description "<tool>" -RestorePointType MODIFY_SETTINGS` (WU) or WMI `root\default` SystemRestore class (OD). Revert: n/a (use rstrui).
src detail: winutil-regtweaks.md, optimizerduck-revitool.md.

### misc.disk-cleanup
Delete contents of user Temp, `%windir%\Temp`, `%windir%\SoftwareDistribution\Download`, `%windir%\Prefetch`, thumbnail cache `%LOCALAPPDATA%\Microsoft\Windows\Explorer\thumbcache*`, Recycle Bin (`Clear-RecycleBin`), `%LOCALAPPDATA%\CrashDumps`, `%SystemDrive%\Windows.old` (scan then clean). Stop wuauserv before clearing SoftwareDistribution. Revert: n/a.
src detail: optimizerduck-revitool.md.

### misc.accessibility-hotkeys-off
`HKCU\Control Panel\Accessibility` (+DEFAULT; strings REG_SZ): `StickyKeys\Flags` (WU toggle 506 = default-on-ish; autounattend 10; WH rec "2", default "510"; Windows default 58), `Keyboard Response\Flags` WH rec "2" (default "126"), `ToggleKeys\Flags` rec "34" (default "62"), `MouseKeys\Flags` rec "130" (default "126"), `HighContrast\Flags` rec "4194" (default "126"); `HKCU\Software\Microsoft\Narrator\NoRoam\WinEnterLaunchEnabled=0`. Sources differ on StickyKeys (use 506 or 10 to suppress the Shift x5 dialog). Revert: defaults above.
src detail: winhance.md, winutil-regtweaks.md.

### misc.notification-prefs
`HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications`: ToastEnabled, LockScreenToastEnabled; `...\Notifications\Settings`: NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND, NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK, NOC_GLOBAL_SETTING_ALLOW_CRITICAL_TOASTS_ABOVE_LOCK, `Windows.SystemToast.CapabilityAccess\Enabled`, `Windows.SystemToast.StartupApp\Enabled`, `Windows.SystemToast.SecurityAndMaintenance\Enabled` (WH rec 1); `Explorer\Advanced\ShowNotificationIcon`; `HKCU\Control Panel\Desktop\DstNotification`; `HKCU\...\CapabilityAccessManager\ConsentStore\location\ShowGlobalPrompts` (WH rec 1). WH rec = 0 (off) for most except Security&Maintenance and location prompts. Revert: defaults 1/delete. Possibly owned by shell group.
src detail: winhance.md (Misc/Notification).

### misc.startup-sound-off
`HKLM\Software\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation\DisableStartupSound=1`; `HKLM\Software\Microsoft\Windows\CurrentVersion\EditionOverrides\UserSetting_DisableStartupSound=1` (WH default 0). Revert: 0.
src detail: winhance.md.

### misc.audio-ducking-off
`HKCU\Software\Microsoft\Multimedia\Audio\UserDuckingPreference=3` (0 mute all, 1 reduce 80% = default, 2 reduce 50%, 3 do nothing = WH rec); `HKCU\Software\Microsoft\Narrator\NoRoam\DuckAudio=0`. Revert: 1 / 1.
src detail: winhance.md.

### misc.voice-activation-off
`HKLM\Software\Microsoft\Windows\CurrentVersion\SpeechOneCore\Settings\AgentActivationEnabled=0` (default 1); `AgentActivationLastUsed=0`. Revert: 1.
src detail: winhance.md.

### misc.netplwiz-autologin
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\PasswordLess\Device\DevicePasswordLessBuildVersion=0` (default 2) shows the "Users must enter a user name and password" checkbox. Revert: 2.
src detail: winhance.md.

### misc.regional-formats
`HKCU\Control Panel\International` (REG_SZ): sShortDate (e.g. yyyy-MM-dd), iFirstDayOfWeek (0=Monday ... 6=Sunday), sDecimal, sList, iMeasure (0 metric, 1 imperial), sMonDecimalSep. WH default en-US: "M/d/yyyy", "6", ".", ",", "0"/"1", ".". Note: WH list shows sList default as ";" and comma option as ";" (inventory inconsistency; verify against raw source before implementing). Revert: stored defaults.
src detail: winhance.md.
