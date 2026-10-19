# Tweak inventory: winutil + Registry-Tweaks-Scripts

Summary:
- Bullets per category: Privacy 19, Appx 38 (34 winutil + 4 ISO-script groups), Features 13, Services 1 bullet + tables, Sched Tasks 2, Performance 12, Gaming 7, Power 6, Security 10, Win Update 6, Explorer/Shell 18, Start/Taskbar 10, Appearance 4, Context Menu 1, Network/DNS 7 (+8 DNS providers), AI 6, Edge/OneDrive/Teams 10, Misc 8. winutil tweaks.json = 67 entries (src ids are WPF* keys); "(ADV)" = in source category "z__Advanced Tweaks - CAUTION"; "(TOGGLE)" = Customize Preferences toggle (value shown = ON state; old = default).
- Registry-Tweaks-Scripts has NO per-service start-type table: services.json is a process/service ignore+safelist for a gaming "suspend" tool (see Services). Its real debloat value is Remove-Edge-ISO.ps1 (offline-image DISM; NOT usable on a live system as-is).
- Caveats: WPFTweaksRevertStartMenu explicitly does not work on newer builds (25H2+); Remove-Edge-ISO targets mounted WIM only; winutil Edge-remove uses dummy MicrosoftEdge.exe trick (live system); autounattend Specialize.ps1 sets NoAutoUpdate then FirstLogon reverts it (net effect: Windows Update left enabled); autounattend uses ViVeTool feature ID 47205210 (Recall-related) and Windows 11 only bypass LabConfig keys.
- winutil appx.json is a list of 34 packages (uninstall UI list, not a fixed preset); no scheduled-task disable list exists in winutil beyond AutoRegBackup task creation.

---

## Privacy & Telemetry
- **Activity History off** — stops publishing/uploading user activities | mech: HKLM\SOFTWARE\Policies\Microsoft\Windows\System\EnableActivityFeed=1 (sic, source value); PublishUserActivities=0; UploadUserActivities=0 (all DWORD) | risk: low | src: WPFTweaksActivity
- **Telemetry off (HKCU/HKLM set)** — disables ad ID, tailored experiences, speech/ink/text harvesting, SIUF feedback, Start tracking | mech: HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo\Enabled=0; HKCU\...\Privacy\TailoredExperiencesWithDiagnosticDataEnabled=0; HKCU\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy\HasAccepted=0; HKCU\Software\Microsoft\Input\TIPC\Enabled=0; HKCU\Software\Microsoft\InputPersonalization\RestrictImplicitInkCollection=1, RestrictImplicitTextCollection=1; ...\InputPersonalization\TrainedDataStore\HarvestContacts=0; HKCU\Software\Microsoft\Personalization\Settings\AcceptedPrivacyPolicy=0; HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection\AllowTelemetry=0; HKCU\...\Explorer\Advanced\Start_TrackProgs=0; HKLM\SOFTWARE\Policies\Microsoft\Windows\System\PublishUserActivities=0; HKCU\Software\Microsoft\Siuf\Rules\NumberOfSIUFInPeriod=0 (all DWORD) | risk: low | src: WPFTweaksTelemetry
- **Telemetry off (commands)** — Defender sample submission off, PS7 telemetry opt-out, drop SIUF period | mech: Set-MpPreference -SubmitSamplesConsent 2; setx machine env POWERSHELL_TELEMETRY_OPTOUT=1; Remove-ItemProperty HKCU\Software\Microsoft\Siuf\Rules\PeriodInNanoSeconds | risk: low | src: WPFTweaksTelemetry
- **Location tracking off** — denies location capability, sensor, maps auto-update, geolocation svc | mech: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location\Value=Deny (String); HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}\SensorPermissionState=0; HKLM\SYSTEM\Maps\AutoUpdateEnabled=0; service lfsvc=Disabled | risk: low | src: WPFTweaksLocation
- **Consumer features off** — stops promoted app installs / Store suggestions | mech: HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent\DisableWindowsConsumerFeatures=1 | risk: low | src: WPFTweaksConsumerFeatures
- **Cloud optimized content off** — mech: HKLM\Software\Policies\Microsoft\Windows\CloudContent\DisableCloudOptimizedContent=1 | risk: low | src: autounattend Specialize.ps1
- **Prevent device companion apps / metadata from network** — blocks vendor apps/ads on device plug-in | mech: HKLM\SOFTWARE\Policies\Microsoft\Windows\Device Metadata\PreventDeviceMetadataFromNetwork=1 | risk: low | src: WPFTweaksPreventDeviceMetadataFromNetwork
- **WPBT off** — blocks vendor firmware injecting executables at boot | mech: HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\DisableWpbtExecution=1 | risk: med (may break OEM anti-theft) | src: WPFTweaksWPBT
- **Store recommended search results off** — mech: icacls "%LocalAppData%\Packages\Microsoft.WindowsStore_8wekyb3d8bbwe\LocalState\store.db" /deny *S-1-1-0:F | risk: med (Store DB locked; hacky) | src: WPFTweaksDisableStoreSearch
- **Bing search in Start off** (TOGGLE, ON=Bing on) — mech: HKCU\Software\Microsoft\Windows\CurrentVersion\Search\BingSearchEnabled=0 to disable (winutil ON=1, old 0) | risk: low | src: WPFToggleBingSearch
- **Background apps off** — mech: HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\GlobalUserDisabled=1 | risk: med (ADV) | src: WPFTweaksDisableBGapps
- **Delivery Optimization off** — mech: HKLM\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization\DODownloadMode=0 | risk: low | src: WPFTweaksDeliveryOptimization
- **Notifications suggestions off** — disables Suggested, StartupApp, OneDrive(SkyDrive), AccountHealth toasts | mech: HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\{Windows.SystemToast.Suggested, Windows.SystemToast.StartupApp, Microsoft.SkyDrive.Desktop, Windows.SystemToast.AccountHealth}\Enabled=0 | risk: low | src: autounattend UserOnce.ps1
- **Start menu activity tracking off** — mech: HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Start_TrackDocs=0, Start_IrisRecommendations=0, Start_AccountNotifications=0; HKCU\...\Start\ShowFrequentList=0, ShowRecentList=0, ShowAllPinsList=0, AllAppsViewMode=2 | risk: low | src: autounattend UserOnce.ps1
- **Game DVR capture off** — mech: HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR\AppCaptureEnabled=0 | risk: low | src: autounattend FirstLogon.ps1
- **Adobe telemetry/activation host block** — appends Ruddernation Adobe URL block list to hosts | mech: download https://github.com/Ruddernation-Designs/Adobe-URL-Block-List/raw/refs/heads/master/hosts -> append %SystemRoot%\System32\drivers\etc\hosts; ipconfig /flushdns | risk: med (ADV; external download) | src: WPFTweaksBlockAdobeNet
- **O&O ShutUp10++ run** — launches external tool with config | mech: button/external exe | risk: med (ADV) | src: WPFOOSUbutton
- **Razer software auto-install block** — mech: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching\SearchOrderConfig=0; HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Installer\DisableCoInstallers=1; empty+deny-write ACL on %SystemRoot%\Installer\Razer (icacls /deny *S-1-1-0:(W)) | risk: med (ADV; disables driver search order globally) | src: WPFTweaksRazerBlock
- **Logitech Download Assistant block** — mech: kill logi_download_assistant; empty and icacls /deny *S-1-1-0:(W) on %ProgramW6432%\LogiDownloadAssistant | risk: low-med (ADV) | src: WPFTweaksLogiBlock

## Appx Bloat Removal
winutil appx.json (34 packages; mech = PackageId; remove via Get-AppxPackage -AllUsers + Remove-AppxPackage, plus Remove-AppxProvisionedPackage online). Flags: [WARN] = description in source warns about side effects.
- **Feedback Hub** | mech: Microsoft.WindowsFeedbackHub | risk: low | src: appx.json
- **Get Help** | mech: Microsoft.GetHelp | risk: low | src: appx.json
- **Outlook for Windows (new)** | mech: Microsoft.OutlookForWindows | risk: low | src: appx.json
- **Microsoft Teams (consumer)** | mech: MSTeams | risk: low | src: appx.json
- **Clipchamp** | mech: Clipchamp.Clipchamp | risk: low | src: appx.json
- **Microsoft 365 / Office Hub** | mech: Microsoft.MicrosoftOfficeHub | risk: low | src: appx.json
- **Media Player (Zune Music)** | mech: Microsoft.ZuneMusic | risk: low | src: appx.json
- **Bing Search** | mech: Microsoft.BingSearch | risk: low | src: appx.json
- **Quick Assist** | mech: MicrosoftCorporationII.QuickAssist | risk: low | src: appx.json
- **Dev Home** | mech: Microsoft.Windows.DevHome | risk: low | src: appx.json
- **Mobile Devices / Cross Device** [WARN: phone mirroring, file transfer, hotspot handoff] | mech: MicrosoftWindows.CrossDevice | risk: med | src: appx.json
- **To Do** | mech: Microsoft.Todos | risk: low | src: appx.json
- **Power Automate** | mech: Microsoft.PowerAutomateDesktop | risk: low | src: appx.json
- **Phone Link** | mech: Microsoft.YourPhone | risk: low | src: appx.json
- **Sticky Notes** | mech: Microsoft.MicrosoftStickyNotes | risk: low | src: appx.json
- **Sound Recorder** | mech: Microsoft.WindowsSoundRecorder | risk: low | src: appx.json
- **Clock** | mech: Microsoft.WindowsAlarms | risk: low | src: appx.json
- **Paint** | mech: Microsoft.Paint | risk: low | src: appx.json
- **Notepad** | mech: Microsoft.WindowsNotepad | risk: med (usually wanted) | src: appx.json
- **Snipping Tool** | mech: Microsoft.ScreenSketch | risk: med (usually wanted) | src: appx.json
- **Copilot** | mech: Microsoft.Copilot | risk: low | src: appx.json
- **Calculator** | mech: Microsoft.WindowsCalculator | risk: med (usually wanted) | src: appx.json
- **Camera** | mech: Microsoft.WindowsCamera | risk: low | src: appx.json
- **Photos** | mech: Microsoft.Windows.Photos | risk: med | src: appx.json
- **News (Bing)** | mech: Microsoft.BingNews | risk: low | src: appx.json
- **Weather (Bing)** | mech: Microsoft.BingWeather | risk: low | src: appx.json
- **Xbox App** | mech: Microsoft.GamingApp | risk: low | src: appx.json
- **Xbox Game Bar** | mech: Microsoft.XboxGamingOverlay | risk: low | src: appx.json
- **Xbox Identity Provider** [WARN: may break MS account sign-in for non-Xbox games/apps] | mech: Microsoft.XboxIdentityProvider | risk: med | src: appx.json
- **Xbox Speech To Text Overlay** | mech: Microsoft.XboxSpeechToTextOverlay | risk: low | src: appx.json
- **Xbox TCUI** [WARN: same as Identity Provider] | mech: Microsoft.Xbox.TCUI | risk: med | src: appx.json
- **Start Experiences App (Widgets board)** | mech: Microsoft.StartExperiencesApp | risk: low | src: appx.json
- **Solitaire Collection** | mech: Microsoft.MicrosoftSolitaireCollection | risk: low | src: appx.json
- **Movies & TV** | mech: Microsoft.ZuneVideo | risk: low | src: appx.json

Remove-Edge-ISO.ps1 Win11 "safe Appx" list (offline Remove-AppxProvisionedPackage on mounted WIM, wildcard match on DisplayName or PackageName prefix; note extra items not in winutil):
- **Extra Appx in Remove-Edge-ISO Win11 list not in winutil** | mech: Microsoft.Getstarted; Microsoft.People; Microsoft.WindowsMaps; Microsoft.Office.OneNote; Microsoft.Xbox* (wildcard, covers all Xbox pkgs); Microsoft.MicrosoftEdge* | risk: low (Getstarted/People/Maps/OneNote) | src: Remove-Edge-ISO.ps1 win11Safe
- **Common Win11 list overlap** | mech: Clipchamp.Clipchamp, Microsoft.GetHelp, Microsoft.MicrosoftSolitaireCollection, Microsoft.PowerAutomateDesktop, Microsoft.Todos, Microsoft.WindowsAlarms, Microsoft.WindowsFeedbackHub, Microsoft.YourPhone, Microsoft.ZuneMusic, Microsoft.ZuneVideo, Microsoft.Windows.DevHome, Microsoft.BingNews, Microsoft.BingWeather, MicrosoftWindows.CrossDevice, MSTeams, Microsoft.OutlookForWindows, Microsoft.Windows.Photos, Microsoft.BingSearch, Microsoft.GamingApp, Microsoft.Copilot, Microsoft.MicrosoftOfficeHub | risk: low | src: Remove-Edge-ISO.ps1 win11Safe
- **Win10-only list extras (ignore for 24H2)** | mech: Microsoft.3DBuilder, Microsoft.Microsoft3DViewer, Microsoft.MixedReality.Portal, Microsoft.OneConnect, Microsoft.SkypeApp, Microsoft.Wallet, microsoft.windowscommunicationsapps | risk: low | src: Remove-Edge-ISO.ps1 win10Safe
- **Post-removal** — runs Optimize-AppxProvisionedPackages on image | mech: DISM /Optimize-ProvisionedAppxPackages | risk: low | src: Remove-Edge-ISO.ps1

## Windows Features & Capabilities
winutil feature.json "Features" (install = Enable-WindowsOptionalFeature) -- add-ons, not debloat:
- **.NET Framework 2/3/4 enable** | mech: NetFx4-AdvSrvs, NetFx3 | risk: low | src: WPFFeaturesdotnet
- **Hyper-V enable** | mech: Microsoft-Hyper-V-All | risk: low | src: WPFFeatureshyperv
- **Legacy media (WMP, DirectPlay) enable** | mech: WindowsMediaPlayer, MediaPlayback, DirectPlay, LegacyComponents | risk: low | src: WPFFeatureslegacymedia
- **WSL enable** | mech: VirtualMachinePlatform, Microsoft-Windows-Subsystem-Linux | risk: low | src: WPFFeaturewsl
- **NFS client enable** | mech: ServicesForNFS-ClientOnly, ClientForNFS-Infrastructure, NFS-Administration; then nfsadmin client stop; HKLM\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default\AnonymousUID=0, AnonymousGID=0; nfsadmin client start; nfsadmin client localhost config fileaccess=755 SecFlavors=+sys -krb5 -krb5i | risk: low | src: WPFFeaturenfs
- **Windows Sandbox enable** | mech: Containers-DisposableClientVM | risk: low | src: WPFFeaturesSandbox
- **Recall feature disable/remove** | mech: Disable-WindowsOptionalFeature -Online -FeatureName Recall [-Remove] | risk: low | src: WPFTweaksWindowsAI, autounattend FirstLogon
- **Legacy F8 boot menu (on/off)** | mech: bcdedit /set bootmenupolicy legacy | standard | risk: low | src: WPFFeatureEnableLegacyRecovery / WPFFeatureDisableLegacyRecovery
- **Disable Reserved Storage** (ADV; re-enable before feature updates) | mech: DISM /Online /Set-ReservedStorageState /State:Disabled | risk: med | src: WPFTweaksReservedStorage
- **Reserved storage off at setup** | mech: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\ShippedWithReserves=0 | risk: med | src: autounattend specialize
- **Component cleanup** | mech: Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase (+ cleanmgr.exe /d C: /VERYLOWDISK) | risk: med (ResetBase irreversible) | src: WPFTweaksDiskCleanup
- **Disable Windows.old removal after install** | mech: Remove-Item C:\Windows.old -Recurse | risk: low | src: autounattend FirstLogon
- **OpenSSH server enable** (opt-in add-on) | mech: capability OpenSSH.Server~~~~0.0.1.0 | risk: low | src: WPFWinUtilSSHServer (feature.json; script not in config)
- Note: no Windows Capability removal list in winutil or Remove-Edge-ISO (only appx + Edge DISM options).

## Services
winutil WPFTweaksServices ("Services - Set to Manual") — start type set, old in parentheses:

| Service | Set to | Orig |
|---|---|---|
| CscService (Offline Files) | Disabled | Manual |
| DiagTrack (Connected User Experiences & Telemetry) | Disabled | Automatic |
| MapsBroker | Manual | Automatic |
| StorSvc | Manual | Automatic |
| SharedAccess (ICS) | Disabled | Automatic |
| lfsvc (Geolocation) | Disabled | Manual | (from WPFTweaksLocation)
| wermgr (Windows Error Reporting) | Disabled | n/a | (from WPFTweaksTelemetry; commands Set-Service)
| WSAIFabricSvc | Disabled | n/a | (WPFTweaksWindowsAI)
| OneSyncSvc | Disabled | n/a | (WPFTweaksRemoveOneDrive)
| BITS | Manual | n/a | (autounattend FirstLogon restore)
| wuauserv | Manual | n/a | (autounattend FirstLogon)
| UsoSvc | Automatic | n/a | (autounattend FirstLogon)
| WaaSMedicSvc | Start=3 (Manual) via HKLM\SYSTEM\CurrentControlSet\Services\WaaSMedicSvc\Start | n/a | (autounattend FirstLogon)

- **Services split threshold** — set SvcHostSplitThresholdInKB to installed RAM in KB to reduce svchost count | mech: HKLM\SYSTEM\CurrentControlSet\Control\SvcHostSplitThresholdInKB = (sum Win32_PhysicalMemory Capacity)/1KB | risk: low | src: WPFTweaksServices; README mentions Service_Split.bat

Registry-Tweaks-Scripts services.json (NOT start-type recommendations: a "gaming mode" suspend tool config). `safelist` = names safe to stop/suspend (comment in source), `ignore` = never touch (35 names).
Safelist services/processes (27): WSearch (stop for gaming), SearchIndexer.exe, SysMain (Superfetch), wuauserv, spoolsv.exe (print spooler), bthserv (Bluetooth), RemoteRegistry, Fax, TabletInputService, wisvc (Insider), vmms.exe, vmcompute.exe (Hyper-V), wmpnetwk.exe, WerFault.exe, msmpeng.exe (only with 3rd-party AV), OneDrive.exe, Teams.exe, Spotify.exe, Zoom.exe, Discord.exe, Slack.exe, Docker Desktop, Podman.exe, w3wp.exe, sqlservr.exe, CrossDeviceResume.exe, AdobeARM.exe.
Ignore (critical/vendor): wininit, winlogon, csrss, smss, services, lsass, svchost, System, explorer, dwm, fontdrvhost, audiodg, spoolsv, winmgmt, WmiPrvSE, taskhostw, rundll32, msmpeng/MsMpEng, MpDefenderCoreService, NisSrv, Realtek (RtkAudUService64, RtkAudioService64), logi_lamparray_service, amdpmfservice, amdfendrsr, atiesrxx, atieclxx, AmdPpkgSvc, NvContainer*, NvDisplay.Container, IAStorDataMgrSvc, IntelCpHDCPSvc, IntelCpHeciSvc.
Candidate service disables derived from the safelist (user choice): WSearch=Disabled/Manual, SysMain=Disabled, bthserv=Manual, RemoteRegistry=Disabled, Fax=Disabled, TabletInputService=Manual/Disabled, wisvc=Disabled | risk: med | src: services.json safelist

## Scheduled Tasks
- **AutoRegBackup task (create)** — daily registry backup at 00:30, re-enabling RegIdleBackup | mech: HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager\EnablePeriodicBackup=1, BackupCount=2; Register-ScheduledTask 'AutoRegBackup' running schtasks /run /i /tn "\Microsoft\Windows\Registry\RegIdleBackup" daily 00:30 as SYSTEM | risk: low | src: WPFFeatureRegBackup
- **UnlockStartLayout task (create, setup-time only)** | mech: task 'UnlockStartLayout' event-triggered, runs wscript UnlockStartLayout.vbs setting HKU\<sid>\Software\Policies\Microsoft\Windows\Explorer\LockedStartLayout=0 | risk: low | src: autounattend
- Note: no scheduled-task disable list in winutil tweaks.json (telemetry handled via registry/services) or Registry-Tweaks-Scripts.

## Performance
- **Visual effects best performance** (ADV) — mech: HKCU\Control Panel\Desktop\DragFullWindows=0 (String); MenuShowDelay=200 (String); HKCU\Control Panel\Desktop\WindowMetrics\MinAnimate=0 (String); HKCU\Control Panel\Keyboard\KeyboardDelay=0; HKCU\...\Explorer\Advanced\ListviewAlphaSelect=0, ListviewShadow=0, TaskbarAnimations=0; HKCU\...\Explorer\VisualEffects\VisualFXSetting=3; HKCU\Software\Microsoft\Windows\DWM\EnableAeroPeek=0; HKCU\Control Panel\Desktop\UserPreferencesMask=binary 90 12 03 80 10 00 00 00 | risk: low | src: WPFTweaksDisplay (same tweak also sets TaskbarMn=0, ShowTaskViewButton=0, SearchboxTaskbarMode=0)
- **Services svchost split** — see Services | risk: low | src: WPFTweaksServices
- **Storage Sense off** (ADV) | mech: HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\01=0 | risk: low | src: WPFTweaksStorage
- **Disable Explorer automatic folder discovery** (grouping lost) | mech: delete HKCU\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags and BagMRU; create ...\Shell\Bags\AllFolders\Shell\FolderType=NotSpecified (String); needs sign out | risk: low | src: WPFTweaksDisableExplorerAutoDiscovery
- **Long paths enable** (TOGGLE) | mech: HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled=1 | risk: low | src: WPFToggleLongPaths; autounattend
- **Temp files cleanup** | mech: Remove-Item %TEMP%\* and %SystemRoot%\Temp\* | risk: low | src: WPFTweaksDeleteTempFiles
- **Multiplane Overlay (MPO) off/on** (combobox) | mech: HKLM\SOFTWARE\Microsoft\Windows\Dwm\OverlayTestMode (DWORD, 5 = off); HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\DisableOverlays (DWORD, 1 = off) (values empty in config; set by UI) | risk: low | src: WPFMultiplaneOverlay
- **Mouse acceleration off** (TOGGLE; ON values shown) | mech: HKCU\Control Panel\Mouse\MouseSpeed=0, MouseThreshold1=0, MouseThreshold2=0 to disable (winutil ON = 1/6/10) | risk: low | src: WPFToggleMouseAcceleration
- **Keyboard repeat delay 0** — see Visual effects (KeyboardDelay=0) | src: WPFTweaksDisplay
- **Hibernation off** — mech: HKLM\System\CurrentControlSet\Control\Session Manager\Power\HibernateEnabled=0; HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings\ShowHibernateOption=0; powercfg.exe /hibernate off | risk: med (breaks Fast Startup/hibernate) | src: WPFTweaksHiber
- **Disk cleanup / component cleanup** — see Windows Features | src: WPFTweaksDiskCleanup
- **Boot menu timeout 0** — mech: bcdedit /set {bootmgr} timeout 0 (only if single OS entry) | risk: low | src: autounattend FirstLogon

## Gaming
- **Game Mode on** (TOGGLE) | mech: HKCU\Software\Microsoft\GameBar\AllowAutoGameMode=1; AutoGameModeEnabled=1 | risk: low | src: WPFToggleGameMode
- **Game DVR / capture off** | mech: HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR\AppCaptureEnabled=0 | risk: low | src: autounattend FirstLogon
- **MPO off** (GPU flicker fix) | see Performance | src: WPFMultiplaneOverlay
- **Teredo off** (gaming latency/compat) | see Network | src: WPFTweaksTeredo
- **Xbox/Game Bar appx removal** | see Appx | src: appx.json
- **Gaming-mode process/service suspend candidates** | see Services (services.json safelist) | src: services.json
- **VC++ / DirectX9 runtime install** | see Misc | src: Install-VCRedistAndDirectX.ps1

## Power
- **Ultimate Performance plan enable** (button; "NOT FOR LAPTOPS") | mech: powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 then set active (script body in WinUtil functions, not in tweaks.json) | risk: med | src: WPFAddUltPerf
- **Ultimate Performance plan remove** | mech: powercfg -delete <guid of duplicated plan> / restore Balanced | risk: low | src: WPFRemoveUltPerf
- **S0 Modern Standby network connectivity** (TOGGLE) | mech: HKCU\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9\ACSettingIndex=1 | risk: low | src: WPFToggleStandbyFix
- **S3 sleep instead of Modern Standby** (TOGGLE) | mech: HKLM\SYSTEM\CurrentControlSet\Control\Power\PlatformAoAcOverride=0 | risk: high (hardware must support S3) | src: WPFToggleS3Sleep
- **Hibernation off** | see Performance | src: WPFTweaksHiber
- **Registry hint:** README links "unlock hidden power options" gists (Win10), no concrete keys in repo.

## Security
- **BitLocker disable** — mech: Disable-BitLocker -MountPoint $Env:SystemDrive | risk: med | src: WPFTweaksDisableBitLocker; autounattend FirstLogon (only if ProtectionStatus On)
- **Prevent auto device encryption at setup** | mech: HKLM\SYSTEM\CurrentControlSet\Control\BitLocker\PreventDeviceEncryption=1 | risk: med | src: autounattend specialize
- **RDP unsigned file warnings off** (ADV) | mech: HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\Client\RedirectionWarningDialogVersion=1; HKCU\SOFTWARE\Microsoft\Terminal Server Client\RdpLaunchConsentAccepted=1 | risk: med-high (lowers security) | src: WPFTweaksDisableWarningForUnsignedRdp
- **WPBT off** | see Privacy | src: WPFTweaksWPBT
- **System restore point create** | mech: HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore\SystemRestorePointCreationFrequency=0; Enable-ComputerRestore; Checkpoint-Computer -RestorePointType MODIFY_SETTINGS | risk: low | src: WPFTweaksRestorePoint
- **Password expiry unlimited (setup)** | mech: net accounts /maxpwage:UNLIMITED | risk: low | src: autounattend
- **Sticky keys off** (TOGGLE) | mech: HKCU\Control Panel\Accessibility\StickyKeys\Flags=506 (default 58); autounattend sets Flags=10 (String) on HKU\.DEFAULT and default user | risk: low | src: WPFToggleStickyKeys; autounattend
- **IPv6 settings** | see Network | src: IPv6 tweaks
- **Win11 hardware bypass at install** (not a runtime tweak) | mech: HKLM\SYSTEM\Setup\LabConfig\{BypassTPMCheck, BypassSecureBootCheck, BypassRAMCheck, BypassCPUCheck, BypassStorageCheck}=1; HKLM\SYSTEM\Setup\MoSetup\AllowUpgradesWithUnsupportedTPMOrCPU=1 | risk: med | src: autounattend windowsPE/specialize
- **OOBE: bypass online account** | mech: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE\BypassNRO=1; OOBE HideOnlineAccountScreens, ProtectYourPC=3, HideEULAPage, HideWirelessSetupInOOBE | risk: low | src: autounattend

## Windows Update
- **Windows Update reset** (fix button; script in functions) | mech: stop wuauserv/bits/etc, clear SoftwareDistribution | risk: low | src: WPFFixesUpdate (feature.json)
- **Update service state restore** | mech: BITS=Manual, wuauserv=Manual, UsoSvc=Automatic, WaaSMedicSvc Start=3; delete WU policy values NoAutoUpdate, AUOptions, UseWUServer, DisableWindowsUpdateAccess, WUServer, WUStatusServer; delete DeliveryOptimization\Config\DODownloadMode | risk: low | src: autounattend FirstLogon
- **Delivery Optimization off** | see Privacy | src: WPFTweaksDeliveryOptimization
- **Razer / Logitech driver auto-install blocks** | see Privacy | src: WPFTweaksRazerBlock, WPFTweaksLogiBlock
- **Disable Windows Update (setup phase only, then reverted)** | mech: HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU\NoAutoUpdate=1; ...\WindowsUpdate\DisableWindowsUpdateAccess=1 | risk: high | src: autounattend Specialize.ps1 (reverted in FirstLogon)
- **NTP server pool.ntp.org** | mech: replaces time.windows.com (w32tm config; script in functions) | risk: low | src: WPFFixesNTPPool
- Note: winutil tweaks.json has no update-policy tweaks (no defer/pause/security-only) in this version.

## Explorer & Shell
- **Show file extensions** (TOGGLE) | mech: HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\HideFileExt=0 | risk: low | src: WPFToggleShowExt
- **Show hidden files** (TOGGLE) | mech: HKCU\...\Explorer\Advanced\Hidden=1 | risk: low | src: WPFToggleHiddenFiles
- **Launch Explorer to This PC; remove Home and Gallery** (ADV) | mech: HKCU\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}\System.IsPinnedToNameSpaceTree=0 (Home); HKCU\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}\System.IsPinnedToNameSpaceTree=0 (Gallery); HKCU\...\Explorer\Advanced\LaunchTo=1 | risk: low | src: WPFTweaksRemoveHomeAndGallery; autounattend (LaunchTo=1)
- **Folder auto-discovery off** | see Performance | src: WPFTweaksDisableExplorerAutoDiscovery
- **Scrollbars always visible** (TOGGLE) | mech: HKCU\Control Panel\Accessibility\DynamicScrollbars=0 | risk: low | src: WPFToggleScrollbars
- **Window snapping** (TOGGLE) | mech: HKCU\Control Panel\Desktop\WindowArrangementActive=1 (String) | risk: low | src: WPFToggleWindowSnapping
- **Num Lock on at startup** (TOGGLE) | mech: HKU\.Default\Control Panel\Keyboard\InitialKeyboardIndicators=2 (String); HKCU same | risk: low | src: WPFToggleNumLock; autounattend
- **Settings Home page hide** (TOGGLE) | mech: HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\SettingsPageVisibility=hide:home (String) | risk: low | src: WPFToggleHideSettingsHome
- **Lock screen disable** (TOGGLE) | mech: HKLM\SOFTWARE\Policies\Microsoft\Windows\Personalization\NoLockScreen=1 | risk: low | src: WPFToggleDisableLockscreen
- **Logon acrylic blur off** (TOGGLE) | mech: HKLM\SOFTWARE\Policies\Microsoft\Windows\System\DisableAcrylicBackgroundOnLogon=1 | risk: low | src: WPFToggleLoginBlur
- **Verbose logon messages** (TOGGLE) | mech: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\VerboseStatus=1 | risk: low | src: WPFToggleVerboseLogon
- **Detailed BSOD** (TOGGLE) | mech: HKLM\SYSTEM\CurrentControlSet\Control\CrashControl\DisplayParameters=1; DisableEmoticon=1 | risk: low | src: WPFToggleDetailedBSoD
- **Time as UTC** (ADV; dual boot) | mech: HKLM\SYSTEM\CurrentControlSet\Control\TimeZoneInformation\RealTimeIsUniversal=1 (QWORD) | risk: med | src: WPFTweaksUTC
- **Notifications and Calendar off** (ADV; also kills Calendar flyout) | mech: HKCU\Software\Policies\Microsoft\Windows\Explorer\DisableNotificationCenter=1; HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications\ToastEnabled=0 | risk: med | src: WPFTweaksDisableNotifications
- **Desktop shortcuts cleanup (setup)** | mech: delete *.lnk in %USERPROFILE%\Desktop and C:\Users\Default\Desktop | risk: low | src: autounattend UserOnce.ps1
- **Start Menu previous layout** (only works pre-25H2; "WILL NOT WORK" on newer) | mech: HKLM\SYSTEM\ControlSet001\Control\FeatureManagement\Overrides\8\3036241548\EnabledState=1 | risk: med; likely n/a on 24H2+ builds | src: WPFTweaksRevertStartMenu
- **Registry backup / BSOD ** see Features and above.
- **New Outlook toggle** (Office; skip) | mech: HKCU\SOFTWARE\Microsoft\Office\16.0\Outlook\Preferences\UseNewOutlook=1; HKCU\Software\Microsoft\Office\16.0\Outlook\Options\General\HideNewOutlookToggle=0; HKCU\Software\Policies\Microsoft\Office\16.0\Outlook\Options\General\DoNewOutlookAutoMigration=0; HKCU\Software\Policies\Microsoft\Office\16.0\Outlook\Preferences\NewOutlookMigrationUserSetting=0 | risk: low | src: WPFToggleNewOutlook

## Start Menu & Taskbar
- **Widgets remove** | mech: stop *Widget* procs; Remove-AppxPackage Microsoft.WidgetsPlatformRuntime and MicrosoftWindows.Client.WebExperience (-AllUsers); restart explorer. Also policy HKLM\SOFTWARE\Policies\Microsoft\Dsh\AllowNewsAndInterests=0 (autounattend) | risk: low | src: WPFTweaksWidget; autounattend
- **Start recommendations off** (TOGGLE; side effect: disables Spotlight on lock screen) | mech: HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start\HideRecommendedSection=1; HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Education\IsEducationEnvironment=1; HKLM\SOFTWARE\Policies\Microsoft\Windows\Explorer\HideRecommendedSection=1 | risk: med | src: WPFToggleStartMenuRecommendations; autounattend FirstLogon
- **Empty Start pins** | mech: HKLM\SOFTWARE\Microsoft\PolicyManager\current\device\Start\ConfigureStartPins={"pinnedList":[]} (String) | risk: low | src: autounattend SetStartPins.ps1
- **Empty taskbar pins (setup)** | mech: LayoutModification XML with empty TaskbarPinList via HKU default\Software\Policies\Microsoft\Windows\Explorer\StartLayoutFile + LockedStartLayout=1; then cleared via UnlockStartLayout task; delete HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband\{Favorites, FavoritesChanges, FavoritesRemovedChanges} and Quick Launch\User Pinned\TaskBar files | risk: low | src: autounattend
- **Taskbar left alignment** (TOGGLE; centered = 1) | mech: HKCU\...\Explorer\Advanced\TaskbarAl=0 (left) | risk: low | src: WPFToggleTaskbarAlignment; autounattend
- **Taskbar search icon hide** (TOGGLE) | mech: HKCU\Software\Microsoft\Windows\CurrentVersion\Search\SearchboxTaskbarMode=0 | risk: low | src: WPFToggleTaskbarSearch; autounattend
- **Task view button hide** (TOGGLE) | mech: HKCU\...\Explorer\Advanced\ShowTaskViewButton=0 | risk: low | src: WPFToggleTaskView; autounattend (HKU DefaultUser)
- **Chat/Teams taskbar icon off** | mech: HKCU\...\Explorer\Advanced\TaskbarMn=0 | risk: low | src: WPFTweaksDisplay
- **End Task on right-click** | mech: HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings\TaskbarEndTask=1 | risk: low | src: WPFTweaksEndTaskOnTaskbar; autounattend
- **Battery percentage in tray** (TOGGLE) | mech: HKCU\...\Explorer\Advanced\IsBatteryPercentageEnabled=1 | risk: low | src: WPFToggleBatteryPercentage

## Appearance
- **Dark mode** (TOGGLE) | mech: HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize\AppsUseLightTheme=0; SystemUsesLightTheme=0; (autounattend also ColorPrevalence=0, EnableTransparency=0 and accent #0078D4 via Explorer\Accent AccentColorMenu/StartColorMenu, DWM\AccentColor, AccentPalette bytes 20-23, DWM\ColorPrevalence=0) | risk: low | src: WPFToggleDarkMode; autounattend SetColorTheme.ps1
- **Visual Effects best performance** | see Performance | src: WPFTweaksDisplay
- **Logon blur / lock screen** | see Explorer & Shell | src: toggles
- **winutil themes.json** (WinUtil own UI themes only; not Windows theming) | src: themes.json

## Context Menu
- **Classic right-click menu (Win10 style)** | mech: create HKCU\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32 with empty default value; restart explorer | risk: low | src: WPFTweaksRightClickMenu; autounattend UserOnce.ps1

## Network & DNS
- **IPv4 preferred over IPv6** (ADV) | mech: HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\DisabledComponents=32 | risk: low | src: WPFTweaksIPv46
- **Teredo disable** (ADV) | mech: DisabledComponents=1 (same key); netsh interface teredo set state disabled | risk: low | src: WPFTweaksTeredo
- **IPv6 disable** (ADV) | mech: DisabledComponents=255; Disable-NetAdapterBinding -Name * -ComponentID ms_tcpip6 | risk: med | src: WPFTweaksDisableIPv6
- **Network reset (fix)** | src: WPFFixesNetwork | risk: low
- **NTP server pool.ntp.org** | see Windows Update | src: WPFFixesNTPPool
- **DNS provider set** (ADV; combobox, dns.json; set on adapters + optional DoH template) | risk: low | src: dns.json
  - Google: 8.8.8.8, 8.8.4.4 / 2001:4860:4860::8888, ::8844 / DoH https://dns.google/dns-query
  - Cloudflare: 1.1.1.1, 1.0.0.1 / 2606:4700:4700::1111, ::1001 / https://cloudflare-dns.com/dns-query
  - Cloudflare_Malware: 1.1.1.2, 1.0.0.2 / 2606:4700:4700::1112, ::1002 / https://security.cloudflare-dns.com/dns-query
  - Cloudflare_Malware_Adult: 1.1.1.3, 1.0.0.3 / 2606:4700:4700::1113, ::1003 / https://family.cloudflare-dns.com/dns-query
  - Open_DNS: 208.67.222.222, 208.67.220.220 / 2620:119:35::35, 2620:119:53::53 / https://doh.opendns.com/dns-query
  - Quad9: 9.9.9.9, 149.112.112.112 / 2620:fe::fe, 2620:fe::9 / https://dns.quad9.net/dns-query
  - AdGuard_Ads_Trackers: 94.140.14.14, 94.140.15.15 / 2a10:50c0::ad1:ff, ::ad2:ff / https://dns.adguard-dns.com/dns-query
  - AdGuard_Ads_Trackers_Malware_Adult: 94.140.14.15, 94.140.15.16 / 2a10:50c0::bad1:ff, ::bad2:ff / https://family.adguard-dns.com/dns-query
  - (BenchmarkEligible=true only for Google and Cloudflare)
- **Internet connectivity check used by installer scripts** pings 8.8.8.8 | src: Install-VCRedistAndDirectX.ps1

## AI (Copilot/Recall)
- **Windows AI disable and remove** (ADV) | mech: HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\SettingsPageVisibility=hide:aicomponents (String); HKLM\SOFTWARE\Policies\WindowsNotepad\DisableAIFeatures=1; add EndOfLife key HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\<SID>\<MicrosoftWindows.Client.CoreAI full name> then Remove-AppxPackage; Get-AppxPackage -AllUsers *Copilot* | Remove-AppxPackage; winget uninstall -e --name "Copilot"; remove Microsoft.MicrosoftOfficeHub; Set-Service WSAIFabricSvc Disabled; Disable-WindowsOptionalFeature -FeatureName Recall | risk: med | src: WPFTweaksWindowsAI
- **Recall feature remove at first logon** | mech: Disable-WindowsOptionalFeature -Online -FeatureName Recall -Remove (if enabled) | risk: low | src: autounattend FirstLogon
- **Recall-related feature flag off via ViVeTool** | mech: ViVeTool v0.3.4 /disable /id:47205210 (downloaded from github.com/thebookisclosed/ViVe) | risk: med (external binary; undocumented flag) | src: autounattend FirstLogon
- **Copilot appx removal** | mech: Microsoft.Copilot | src: appx.json; Remove-Edge-ISO win11Safe
- **Notepad AI off** | mech: HKLM\SOFTWARE\Policies\WindowsNotepad\DisableAIFeatures=1 | risk: low | src: WPFTweaksWindowsAI
- **Bing/Start Experiences removal** | see Appx | src: appx.json

## Edge/OneDrive/Teams
- **Edge debloat via policies** (ADV) | mech: HKLM\SOFTWARE\Policies\Microsoft\EdgeUpdate\CreateDesktopShortcutDefault=0; HKLM\SOFTWARE\Policies\Microsoft\Edge\{PersonalizationReportingEnabled=0, ShowRecommendationsEnabled=0, HideFirstRunExperience=1, UserFeedbackAllowed=0, ConfigureDoNotTrack=1, AlternateErrorPagesEnabled=0, EdgeCollectionsEnabled=0, EdgeShoppingAssistantEnabled=0, MicrosoftEdgeInsiderPromotionEnabled=0, ShowMicrosoftRewards=0, WebWidgetAllowed=0, DiagnosticData=0, EdgeAssetDeliveryServiceEnabled=0, WalletDonationEnabled=0, DefaultBrowserSettingsCampaignEnabled=0}; HKLM\SOFTWARE\Policies\Microsoft\Edge\ExtensionInstallBlocklist\1=ofefcgjbeghpigppfmkologfjadafddi (String) | risk: low | src: WPFTweaksEdgeDebloat
- **Edge startup boost / background mode off** | mech: HKLM\Software\Policies\Microsoft\Edge\Recommended\BackgroundModeEnabled=0; StartupBoostEnabled=0; HKLM\Software\Policies\Microsoft\Edge\HideFirstRunExperience=1 | risk: low | src: autounattend
- **Edge desktop shortcut delete** | mech: Remove C:\Users\Public\Desktop\Microsoft Edge.lnk | risk: low | src: autounattend
- **Edge remove (live system, winutil)** (ADV) | mech: create dummy %SystemRoot%\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe then run "%ProgramFiles(x86)%\Microsoft\Edge\Application\*\Installer\setup.exe --uninstall --system-level --force-uninstall --delete-profile" | risk: high (may be redownloaded by updates; WebView2 dependency) | src: WPFTweaksRemoveEdge
- **Edge remove (offline ISO, Registry-Tweaks-Scripts)** — mounted install.wim, DISM /image:<mount> with /Remove-Edge (all), /Remove-EdgeBrowser, /Remove-EdgeWebView; Win10 fallback deletes Program Files (x86)\Microsoft; also removes Appx Microsoft.MicrosoftEdge* | risk: high (offline-only, undocumented DISM switches, requires newer DISM) | src: Remove-Edge-ISO.ps1 options 1-3, 9
- **OneDrive remove** (ADV) | mech: icacls %OneDrive% /deny *S-1-5-32-544:(D,DC); run %SystemRoot%\System32\OneDriveSetup.exe /uninstall; kill FileCoAuth, Explorer; delete %LocalAppData%\Microsoft\OneDrive and %ProgramData%\Microsoft OneDrive; icacls grant back; remove empty OneDrive folder and user env var OneDrive; Set-Service OneSyncSvc Disabled | risk: high | src: WPFTweaksRemoveOneDrive
- **OneDrive uninstall at first logon** | mech: OneDriveSetup.exe /uninstall; delete HKCU\Software\Microsoft\Windows\CurrentVersion\Run\OneDriveSetup; HKLM\Software\Policies\Microsoft\Windows\OneDrive\DisableFileSyncNGSC=0 | risk: med | src: autounattend FirstLogon
- **Teams (consumer) appx** | mech: MSTeams | see Appx | src: appx.json
- **Brave debloat** (ADV) | mech: HKLM\SOFTWARE\Policies\BraveSoftware\Brave\{BraveRewardsDisabled=1, BraveWalletDisabled=1, BraveVPNDisabled=1, BraveAIChatEnabled=0, BraveStatsPingEnabled=0, BraveNewsDisabled=1, BraveTalkDisabled=1, TorDisabled=1, BraveP3AEnabled=0, UrlKeyedAnonymizedDataCollectionEnabled=0, SafeBrowsingExtendedReportingEnabled=0, MetricsReportingEnabled=0} | risk: low | src: WPFTweaksBrave Debloat
- **Outlook (new) appx** | mech: Microsoft.OutlookForWindows | see Appx | src: appx.json

## Misc
- **Restore point create** | see Security | src: WPFTweaksRestorePoint
- **Install-VCRedistAndDirectX.ps1** — checks internet (ping 8.8.8.8), then silent-installs VC++ redist AIO + DirectX9 end-user runtime (supports -OfflineMode); one-liner: offline/online runtime installer | src: Install-VCRedistAndDirectX.ps1
- **Install-VCRedistAndDirectX_gitlab.ps1** — same, but downloads VisualCppRedist_AIO_x86_x64.exe from a GitLab upload when offline packages are absent | src: Install-VCRedistAndDirectX_gitlab.ps1
- **Legacy panel launchers** (non-tweak): compmgmt.msc, control, main.cpl, ncpa.cpl, powercfg.cpl, appwiz.cpl, intl.cpl, wscui.cpl, mmsys.cpl, sysdm.cpl, timedate.cpl, firewall.cpl, rstrui.exe, printers shell:::{A8A91A66-3A7D-4424-8D24-04E180695C7A} | src: feature.json
- **Fix buttons (no config bodies)**: Autologon, DISM/SFC scan, WinGet reinstall | src: WPFPanelAutologin, WPFPanelDISM, WPFFixesWinget
- **ISO tooling in Remove-Edge-ISO**: WIM optimize (Export-WindowsImage), ESD export (dism /Export-Image /Compress:recovery), boot.wim optimize, oscdimg ISO generation | src: Remove-Edge-ISO.ps1 options 4-6, 8
- **Setup-time UX**: Unattend skips EULA, hides OOBE wireless/online-account screens | src: autounattend
- **Brave/Edge notes**: README mentions Svchost split threshold, UWP bloat list from Edugeek, reg_tweaks directory (MajorGeeks tweak pack) not present in repo root listing (only scripts + services.json found) | src: README.md
