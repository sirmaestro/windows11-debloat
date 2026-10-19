# group3 mechanics: Services, Scheduled Tasks, Performance, Gaming, Power

Conventions: service start type 4=Disabled, 3=Manual, 2=Automatic, 1=System, 0=Boot; set via `HKLM\SYSTEM\CurrentControlSet\Services\<svc>\Start` (DWORD) or Set-Service/sc; run as TrustedInstaller (ReviOS runs services BEFORE registry tasks). "+DEFAULT" = also write to HKU\.DEFAULT / default user hive (per-user mirroring). Defaults are Windows 11 24H2 stock unless noted. No source defines Xbox/Edge/OneDrive scheduled tasks (see Scheduled Tasks note).

## Services

### svc.reviOS-service-set
Bundle of the exact ReviOS `services.yml` changes (all `Start=` under `HKLM\SYSTEM\ControlSet001\Services\<name>`): dam=4, GpuEnergyDrv=4, NetBT=4, Telemetry (Intel)=4, diagnosticshub.standardcollector.service=4, WerSvc=4, DiagTrack=4, wisvc=4, PcaSvc=4, WdiServiceHost=4, WdiSystemHost=4, tcpipreg=4, edgeupdate=3 (Manual), Wecsvc=4, UCPD=4 (+ disable task `\Microsoft\Windows\AppxDeploymentClient\UCPD velocity`), condrv=2 (Automatic). Reverted by ReviOS and NOT part of the bundle: bam (=1, disabling breaks Efficiency Mode), Ndu (=2), DPS (=2, needed for Data Usage and Task Manager network column), GraphicsPerfSvc (=3), Beep (=1). Driver services (dam, GpuEnergyDrv, NetBT) need reboot. Defaults: dam=1(System), GpuEnergyDrv=3, NetBT=1, DiagTrack=2, WerSvc=3, wisvc=3, PcaSvc=3, WdiServiceHost=3, WdiSystemHost=3, Wecsvc=3, UCPD=2, edgeupdate=2 (delayed), condrv=3. Telemetry/tcpipreg only exist on some systems; skip if absent. The individual svc.* lines marked "in RV set" are the same changes split out; applying both is idempotent. Revert: restore defaults above.
src detail: playbook.md (Services); optimizerduck-revitool.md (conflict list)

### svc.diagtrack
`DiagTrack` Start=4. RV, WU, OD disable; WH recommends only Manual (3), default Automatic (2). Also stop service. WU's WPFTweaksServices sets Disabled too. Conflict: OD's bulk table (svc.od-bulk-profile) lists DiagTrack in its Disabled set (consistent) but sets WerSvc/PcaSvc/DcpSvc/dmwappushservice/diagnosticshub back to Manual. Telemetry policy registry keys live in priv group. Revert: Start=2.
src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md

### svc.dmwappushservice-dcpsvc
`dmwappushservice` Start=4, `DcpSvc` (Data Collection and Publishing) Start=4. Only OD's DisableTelemetry applies it; OD's own bulk table resets both to Manual (order-dependent conflict). dmwappushservice default Manual (3); some MDM/WAP push features need it (rare on home PCs). Revert: Start=3.
src detail: optimizerduck-revitool.md (Services)

### svc.diagnosticshub
`diagnosticshub.standardcollector.service` Start=4. RV and OD (DisableTelemetry); OD bulk table resets to Manual. Default Manual (3). Revert: Start=3.
src detail: playbook.md, optimizerduck-revitool.md

### svc.wersvc
`WerSvc` Start=4. RV, OD (DisableErrorReporting), WH (Disabled option, recommended/default Manual). WU additionally disables `wermgr` via Set-Service (WPFTweaksTelemetry). RS safelist suggests stopping WerFault.exe for gaming mode. Registry half (OD): `HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting\Disabled=1` is in priv group. Default Manual (3). Revert: Start=3.
src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md

### svc.pcasvc
`PcaSvc` Start=4. RV, OD (DisableErrorReporting), WH (Disabled option; WH recommended Manual). OD bulk table resets to Manual. Default Manual (3). Revert: Start=3.
src detail: playbook.md, winhance.md, optimizerduck-revitool.md

### svc.wisvc
`wisvc` Start=4. RV, WH, RS safelist. Default Manual (3). Revert: Start=3. Only affects Insider enrolment.
src detail: playbook.md, winhance.md, winutil-regtweaks.md

### svc.wdi-hosts
`WdiServiceHost` Start=4, `WdiSystemHost` Start=4. RV only. Defaults Manual (3). Disables Windows troubleshooters' diagnostic hosts. Revert: Start=3.
src detail: playbook.md

### svc.dam
`dam` (Desktop Activity Moderator, kernel driver) Start=4. RV only; risk med. Default 1 (System). Revert: Start=1. Reboot.
src detail: playbook.md

### svc.gpuenergydrv
`GpuEnergyDrv` Start=4. RV only. Default 3. Revert: Start=3. Reboot.
src detail: playbook.md

### svc.netbt
`NetBT` Start=4. RV only; breaks NetBIOS name resolution (legacy SMB browsing, hostnames without DNS). Default 1 (System). Revert: Start=1. Reboot.
src detail: playbook.md

### svc.intel-telemetry
Service named `Telemetry` (Intel) Start=4. RV only; skip if service absent. Revert: Start=2 or 3 depending on vendor install.
src detail: playbook.md

### svc.tcpipreg-wecsvc
`tcpipreg` Start=4 (RV comment: "experimental"), `Wecsvc` (Windows Event Collector) Start=4. RV only. Wecsvc default Manual (3). Revert to defaults.
src detail: playbook.md

### svc.ucpd
`UCPD` driver Start=4 (allows changing default-app hash protection) plus task disable (see task.ucpd-velocity: `Disable-ScheduledTask -TaskPath '\Microsoft\Windows\AppxDeploymentClient' -TaskName 'UCPD velocity'`). RV only, risk med. Default 2 (Auto). Windows updates can re-enable the driver/task (drift). Reboot. Revert: Start=2, enable task.
src detail: playbook.md

### svc.edgeupdate-manual
`edgeupdate` Start=3 (NOT 4). RV comment: Disabled breaks WebView installation via Visual Studio. OD bulk table lists edgeupdate, edgeupdatem, MicrosoftEdgeElevationService as Manual too. Default edgeupdate Automatic (delayed). Interacts with the edge group (Edge removal). Revert: Start=2.
src detail: playbook.md, optimizerduck-revitool.md

### svc.condrv-auto
`condrv` Start=2. RV fix for error 0xd000003a (ReviOS issue #184). Default 3. Revert: Start=3.
src detail: playbook.md

### svc.sysmain-off
`SysMain` Start=4. Sources: WH (option Disabled, "recommended for SSD", Automatic recommended for HDD, default 2), RT/OD `superfetch disable` (SysMain Start=4, `rdyboost` Start=4, remove `rdyboost` from `HKLM\SYSTEM\CurrentControlSet\Control\Class\{71a27cdd-812a-11d0-bec7-08002be2092f}\LowerFilters`, EnablePrefetcher=0, EnableSuperfetch=0 under `...\Session Manager\Memory Management\PrefetchParameters`, `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\EMDMgmt\GroupPolicyDisallowCaches=1`, `AllowNewCachesByDefault=0`), RS safelist (gaming-mode suspend). ReviOS reverted this (`revitool tweaks performance superfetch enable`): disabling breaks `defrag c: -b`. Enable restores SysMain Start=2, rdyboost Start=0, EnablePrefetcher=3, EnableSuperfetch=3 (RT only on HDD). Recommendation: leave enabled. Revert: Start=2.
src detail: playbook.md (Performance revert), winhance.md, optimizerduck-revitool.md, winutil-regtweaks.md

### svc.wsearch
`WSearch` Start=3 or 4. WH: Manual "recommended", Disabled breaks Outlook search and slows Start/Explorer (risk high); default Automatic (delayed). OD bulk table: Manual. RS safelist: stop for gaming. ReviOS keeps it but throttles via perf.search-indexing-power. Revert: Start=2.
src detail: winhance.md, winutil-regtweaks.md, optimizerduck-revitool.md, playbook.md

### svc.spooler
`Spooler` Start=3/4. WH recommends Manual, risk high (default Automatic); OD bulk: Manual; RS safelist (spoolsv). Note RS "ignore" list also lists spoolsv (conflicting hint). Revert: Start=2.
src detail: winhance.md, winutil-regtweaks.md, optimizerduck-revitool.md

### svc.fax
`Fax` Start=4. WH (recommended Disabled, default Disabled on most), OD bulk Disabled, RS safelist. Revert: Start=3.
src detail: winhance.md, optimizerduck-revitool.md, winutil-regtweaks.md

### svc.remote-registry
`RemoteRegistry` Start=4. OD bulk Disabled, RS safelist. Default Disabled on Win11 client already (Manual on some SKUs). Revert: Start=3.
src detail: optimizerduck-revitool.md, winutil-regtweaks.md

### svc.bluetooth
`bthserv` Start=3 or 4 (RS safelist: Manual/Disabled for gaming). OD keeps BthAvctpSvc and BthHFSrv Automatic and bthserv Manual. Default Manual (3). Disabling kills all Bluetooth devices. Revert: Start=3.
src detail: winutil-regtweaks.md, optimizerduck-revitool.md

### svc.xbox-services
`XblAuthManager`=4, `XblGameSave`=4, `XboxNetApiSvc`=4 (WH options; WH recommended/default Manual). `XboxGipSvc` is intentionally excluded: ReviOS service-grouping note says svchost regrouping must not break XboxGipSvc (Xbox accessories). OD bulk table keeps all four Manual. Independent from Xbox app removal (appx group). Default Manual (3). Revert: Start=3.
src detail: winhance.md, optimizerduck-revitool.md, playbook.md

### svc.cdp-connected-devices
`CDPSvc`=4 and `CDPUserSvc`=4 (the latter is a per-user template service: also set `HKLM\SYSTEM\CurrentControlSet\Services\CDPUserSvc\Start`; per-session instance has a _xxxxx suffix). WH only; risk med. Defaults: CDPSvc Automatic (delayed), CDPUserSvc Automatic. Revert: Start=2.
src detail: winhance.md

### svc.geolocation-maps
`lfsvc` Start=4 (WU Disabled, default Manual; WH default Manual with Disabled option); `MapsBroker` Start=3 (WU, WH recommended Manual; OD bulk lists Auto-delayed, default Automatic delayed). Registry location privacy (priv group) is separate; OD's DisableLocationAndSensors also disables task Maps update (task.maps-update). Revert: lfsvc=3, MapsBroker=2 (delayed).
src detail: winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md

### svc.winutil-set
winutil "Services - Set to Manual" non-RV entries: `CscService` Start=4 (orig Manual), `SharedAccess` Start=4 (orig Automatic; breaks ICS/Mobile Hotspot), `StorSvc` Start=3 (orig Automatic), `MapsBroker` Start=3. `DiagTrack` (see svc.diagtrack), `lfsvc` (svc.geolocation-maps), `wermgr` (svc.wersvc), `WSAIFabricSvc` (svc.ai-fabric), `OneSyncSvc` (svc.onesyncsvc) are listed in their own items. Revert: restore orig values above. winutil FirstLogon (autounattend) also resets BITS=3, wuauserv=3, UsoSvc=2, `WaaSMedicSvc\Start=3` (belongs in upd group).
src detail: winutil-regtweaks.md

### svc.retail-demo
`RetailDemo` Start=4. WH, OD bulk Disabled. Default Manual. Revert: Start=3.
src detail: winhance.md, optimizerduck-revitool.md

### svc.smartcard
`SCardSvr`, `ScDeviceEnum`, `SCPolicySvc` Start=4. WH only (recommended/default Manual). Revert: Start=3.
src detail: winhance.md

### svc.phone-nfc-sms
`PhoneSvc`=4, `WalletService`=4, `SEMgrSvc`=4, `SmsRouter`=4. WH only (default Manual). Revert: Start=3.
src detail: winhance.md

### svc.mixed-reality
`MixedRealityOpenXRSvc` Start=4. WH only (WH default Disabled already per its table). Revert: Start=3.
src detail: winhance.md

### svc.wmp-network-sharing
`WMPNetworkSvc` Start=4. WH (recommended Disabled), RS safelist (wmpnetwk.exe). Default Manual. Revert: Start=3.
src detail: winhance.md, winutil-regtweaks.md

### svc.parental-controls
`WpcMonSvc` Start=4. WH only. Default Manual. Revert: Start=3.
src detail: winhance.md

### svc.biometric
`WbioSrvc` Start=4. WH only; risk high; breaks Windows Hello. Default Manual. Revert: Start=3.
src detail: winhance.md

### svc.sensors
`SensrSvc`=4, `SensorDataService`=4. WH only; desktop PCs. OD's location tweak (priv group) also sets DisableSensors=1 policy. Default Manual. Revert: Start=3.
src detail: winhance.md

### svc.telephony
`TapiSrv` Start=4. WH only; WH advises leaving Manual (default). Revert: Start=3.
src detail: winhance.md

### svc.remote-desktop
`TermService`, `SessionEnv`, `UmRdpService` Start=4. WH (all three, recommended Manual = default); OD bulk keeps Manual; RS none. Revert: Start=3.
src detail: winhance.md, optimizerduck-revitool.md

### svc.ras-vpn
`RasMan` Start=4 (risk high) and `RasAuto` Start=4 (risk med). WH only; defaults Manual. Revert: Start=3.
src detail: winhance.md

### svc.mobile-hotspot
`icssvc` Start=4. WH only (default Manual). Revert: Start=3.
src detail: winhance.md

### svc.tablet-input
`TabletInputService` Start=4 and `HKCU\Software\Microsoft\input\IsInputAppPreloadEnabled=0` (DWORD) (WH also renames `C:\Windows\SystemApps\MicrosoftWindows.Client.CBS_cw5n1h2txyewy\TextInputHost.exe` on build >= 22000 unless zh/ja/ko IME installed; Win11-only). WH recommended Disabled; RS safelist: Manual/Disabled. Breaks emoji panel, touch keyboard, handwriting, Xbox controller keyboard. Default Manual; revert Start=3, IsInputAppPreloadEnabled=1, restore TextInputHost.exe name.
src detail: winhance.md, winutil-regtweaks.md

### svc.spot-verifier
`svsvc` Start=3 (WH recommended = default Manual). No change on stock Windows; listed only because WH exposes it. Revert: none.
src detail: winhance.md

### svc.legacy-disabled-od
OD bulk-table Disabled set minus those covered elsewhere: AJRouter, AppVClient, AssignedAccessManagerSvc, DialogBlockingService, HomeGroupListener, HomeGroupProvider, NetTcpPortSharing, RemoteAccess, UevAgentService, shpamsvc, ssh-agent, tzautoupdate (all Start=4). Others in OD's Disabled list: DiagTrack, Fax, RemoteRegistry, RetailDemo (own items). Most default Manual/Disabled already (HomeGroup* gone in 24H2). tzautoupdate off stops automatic timezone; ssh-agent off breaks OpenSSH key agent. Revert: Start=3 (tzautoupdate default Manual, ssh-agent Disabled default).
src detail: optimizerduck-revitool.md

### svc.ai-fabric
`WSAIFabricSvc` Start=4. WU (WPFTweaksWindowsAI), WH (IsWindows11Only; WH default Automatic). Pairs with Copilot/Recall removal. Revert: Start=2.
src detail: winutil-regtweaks.md, winhance.md

### svc.onesyncsvc
`OneSyncSvc` Start=4 (template service with per-user `OneSyncSvc_xxxxx` instance). WU runs it in WPFTweaksRemoveOneDrive. Breaks Mail/Calendar/People sync. Default Automatic (delayed). Revert: Start=2.
src detail: winutil-regtweaks.md

### svc.wpn-services
`Wpn*` services (WpnService, WpnUserService_*) Start=4 under `HKLM\SYSTEM\ControlSet001\Services\` (enable: Start=2). From revitool notification "aggressive off". Kills all toast/push notifications. Revert: Start=2.
src detail: optimizerduck-revitool.md

### svc.ctfmon-input
revitool `ctfmon-input disable`: `HKLM\Software\Microsoft\Input\InputServiceEnabled=0`, `InputServiceEnabledForCCI=0`; `HKLM\SYSTEM\ControlSet001\Services\TextInputManagementService\Parameters\ServiceDll` (REG_EXPAND_SZ) = `%SystemRoot%\System32\MSCTF.DLL`. Enable: 1,1 and ServiceDll `%SystemRoot%\System32\TabSvc.dll`. Est. risk high. Conflicts svc.tablet-input in effect (both touch input). Note ReviOS itself does not apply this.
src detail: optimizerduck-revitool.md

### svc.svchost-split
Several mechanisms, pick one. (1) ReviOS: `revitool tweaks performance service-grouping set recommended` = `HKLM\SYSTEM\CurrentControlSet\Control\SvcHostSplitThresholdInKB=0x380000` (default, 3670016) plus per-service `HKLM\SYSTEM\ControlSet001\Services\<svc>\SvcHostSplitDisable=1` (TrustedInstaller) for ~70 services (BFE, mpssvc, PlugPlay, Power, RpcSs, SysMain, wuauserv, Schedule, Themes, UserManager, Winmgmt, Dnscache, ... plus Wpn/CDPUser/OneSync user services); keeps XboxGipSvc working. revitool modes: forced=0xFFFFFFFF; recommended/disabled=0x380000. (2) WU/OD: set SvcHostSplitThresholdInKB to installed RAM in KB = sum(Win32_PhysicalMemory.Capacity)/1KB (risk med; WU also ships Service_Split.bat). (3) WH dropdown: Default 3670016 (rec), 4 GB=4194304, 6 GB=6291456, 8 GB=8388608 etc. ReviOS earlier used `SvcHostSplitThresholdInKB=3670016` and reverted it for the revitool approach. Requires reboot. Revert: SvcHostSplitThresholdInKB=3670016 (0x380000), delete SvcHostSplitDisable values.
src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md

### svc.services-pipe-timeout
`HKLM\SYSTEM\CurrentControlSet\Control\ServicesPipeTimeout` DWORD=30000 (rec/on), 60000 default/off (delete is also default). WH only (id gaming-performance-background-services). Reboot. Revert: delete or 60000.
src detail: winhance.md

### svc.tm-monitoring
revitool `tm-monitoring disable`: `GraphicsPerfSvc`, `Ndu`, `DPS` Start=4 under `HKLM\SYSTEM\ControlSet001\Services\`. ReviOS reverted/commented out in services.yml: Ndu=2, GraphicsPerfSvc=3, DPS=2 (DPS needed for Data Usage page and Task Manager network). Recommendation: do not apply. Defaults: GraphicsPerfSvc=3, Ndu=2, DPS=2. Revert: Start values above.
src detail: optimizerduck-revitool.md, playbook.md

### svc.bam
`bam` Start=4 disabled then reverted by ReviOS to Start=1: disabling breaks Efficiency Mode. Do not apply. Default 1 (System).
src detail: playbook.md

### svc.beep
`Beep` Start=4 then reverted by ReviOS to 1. Do not apply. Default 1.
src detail: playbook.md

### svc.od-bulk-profile
OD ConfigureServices: ~190-service start-type table (see "Full service table" below). Conflicts: resets WerSvc, PcaSvc, DcpSvc, dmwappushservice, diagnosticshub.standardcollector.service back to Manual after OD's own telemetry/error-reporting tweaks (order-dependent); also sets DPS=Automatic (consistent with ReviOS revert), edgeupdate=Manual (consistent), sets wuauserv/UsoSvc/WaaSMedicSvc Manual. Not recommended as a whole.
src detail: optimizerduck-revitool.md

### svc.msi-safeboot
`HKLM\SYSTEM\ControlSet001\Control\SafeBoot\Minimal\MSIServer\(default)=Service` and `...\SafeBoot\Network\MSIServer\(default)=Service` (REG_SZ). RV (misc/msi-installer-in-safe-mode.yml). Revert: delete the two keys.
src detail: playbook.md

### Full service start-type table (compact)

Legend of source: RV=ReviOS, WU=winutil, WH=Winhance, OD=optimizerDuck (+RT=revitool), RS=Registry-Tweaks-Scripts services.json. A = Automatic, AD = Automatic (delayed), M = Manual, D = Disabled. "RV-rev" = ReviOS explicitly reverted. CONFLICT marks disagreement.

| Service | Recommended start | Source(s) | Note |
|---|---|---|---|
| dam | D | RV | driver |
| GpuEnergyDrv | D | RV | driver |
| NetBT | D | RV | breaks NetBIOS |
| Telemetry (Intel) | D | RV | |
| diagnosticshub.standardcollector.service | D | RV,OD | CONFLICT: OD bulk table says M |
| WerSvc | D | RV,OD,WH(option),WU(wermgr) | CONFLICT: OD bulk M; WH default M |
| DiagTrack | D | RV,WU,OD(telemetry+bulk); WH M | |
| wisvc | D | RV,WH(opt),RS | |
| PcaSvc | D | RV,OD,WH(opt) | CONFLICT: OD bulk M; WH rec M |
| WdiServiceHost / WdiSystemHost | D | RV | |
| tcpipreg | D | RV | |
| Wecsvc | D | RV | |
| UCPD | D | RV | + task |
| edgeupdate / edgeupdatem / MicrosoftEdgeElevationService | M | RV (edgeupdate), OD | never D (WebView) |
| condrv | A | RV | fix |
| bam | keep (1) | RV-rev | disable breaks Efficiency Mode |
| Ndu | keep (A) | RV-rev; RT disables | |
| DPS | keep (A) | RV-rev; RT disables; OD bulk A | CONFLICT RT vs RV |
| GraphicsPerfSvc | keep (M) | RV-rev; RT disables | |
| Beep | keep (1) | RV-rev | |
| SysMain | keep (A) | RV-rev; WH D-for-SSD/A-for-HDD; RT D; RS safelist | breaks defrag -b |
| rdyboost | keep | RT | |
| WSearch | M (A default) | WH M rec; OD M; RS safelist | |
| Spooler | M | WH M rec; OD M; RS | |
| Fax | D | WH,OD,RS | |
| RemoteRegistry | D | OD,RS | |
| bthserv | M | RS,OD | |
| TabletInputService | D (opt) | WH,RS | breaks emoji panel |
| CDPSvc / CDPUserSvc | D (opt) | WH | |
| lfsvc | D (opt) | WU D; WH M; OD M | CONFLICT WU vs OD |
| MapsBroker | M | WU M; WH M; OD AD | |
| StorSvc | M | WU | |
| SharedAccess | D | WU | breaks ICS |
| CscService | D | WU | |
| WSAIFabricSvc | D | WU,WH | |
| OneSyncSvc | D | WU | |
| RetailDemo | D | WH,OD | |
| SCardSvr / ScDeviceEnum / SCPolicySvc | D (opt) | WH | |
| PhoneSvc / WalletService / SEMgrSvc / SmsRouter | D (opt) | WH | |
| MixedRealityOpenXRSvc | D | WH | |
| WMPNetworkSvc | D | WH,RS | |
| icssvc | D (opt) | WH | |
| WpcMonSvc | D (opt) | WH | |
| svsvc | M | WH | no change |
| RasMan / RasAuto | M (default) | WH | VPN |
| TermService / SessionEnv / UmRdpService | M | WH,OD | |
| XblAuthManager / XblGameSave / XboxNetApiSvc | M or D | WH,OD | |
| XboxGipSvc | M | OD | RV: must not break |
| WbioSrvc | M (default) | WH | |
| TapiSrv | M | WH | |
| SensrSvc / SensorDataService | M | WH | |
| BITS | M or AD | WU(M), OD AD | upd group |
| wuauserv | M | WU,OD,RS safelist | upd group |
| UsoSvc | A (WU) / M (OD) | WU,OD | CONFLICT; upd group |
| WaaSMedicSvc | M | WU,OD | upd group |
| sppsvc, wscsvc | AD | OD | |
| Defender services | n/a | RV | handled by sec group |
| AJRouter, AppVClient, AssignedAccessManagerSvc, DialogBlockingService, HomeGroupListener, HomeGroupProvider, NetTcpPortSharing, RemoteAccess, UevAgentService, shpamsvc, ssh-agent, tzautoupdate | D | OD | |
| Wpn* | D (aggressive) | RT | |
| TextInputManagementService | see svc.ctfmon-input | RT | |
| OD Automatic list | A | OD | AudioEndpointBuilder, Audiosrv, BFE, BrokerInfrastructure, BthAvctpSvc, BthHFSrv, CoreMessagingRegistrar, CryptSvc, DPS, DcomLaunch, Dhcp, DispBrokerDesktopSvc, Dnscache, EventLog, EventSystem, FontCache, KeyIso, LSM, LanmanWorkstation, MpsSvc, Netman, NlaSvc, PlugPlay, Power, ProfSvc, RpcEptMapper, RpcSs, SENS, SamSs, Schedule, ShellHWDetection, SystemEventsBroker, Themes, TrkWks, UserManager, VaultSvc, Wcmsvc, Winmgmt, WlanSvc, iphlpsvc, nsi, tiledatamodelsvc |
| OD Manual list (notable) | M | OD | wuauserv, UsoSvc, WaaSMedicSvc, WSearch, Spooler, LanmanServer, TermService, SessionEnv, UmRdpService, WinRM, XblAuthManager, XblGameSave, XboxGipSvc, XboxNetApiSvc, edgeupdate, edgeupdatem, MicrosoftEdgeElevationService, lfsvc, W32Time, VSS, wbengine, vmic*/vm* guest services; all remaining ~140 services in OD's table default to Manual |
| RS "never touch" list | n/a | RS | wininit, winlogon, csrss, smss, services, lsass, svchost, System, explorer, dwm, fontdrvhost, audiodg, spoolsv, winmgmt, WmiPrvSE, taskhostw, rundll32, MsMpEng, MpDefenderCoreService, NisSrv, Realtek/Logitech/AMD/NVIDIA/Intel vendor services |
| RS gaming-suspend candidates | temp stop | RS | WSearch, SysMain, wuauserv, spoolsv, bthserv, RemoteRegistry, Fax, TabletInputService, wisvc, vmms, vmcompute, wmpnetwk, WerFault, msmpeng (3rd-party AV only), OneDrive, Teams, Spotify, Zoom, Discord, Slack, Docker Desktop, Podman, w3wp, sqlservr, CrossDeviceResume, AdobeARM (a runtime "game mode" tool config, not start-type changes) |

The inventory records OD's table as lists by category, not the complete 190 names; "all remaining Manual" is inferred from OD's description ("most Manual, core ones Automatic"). Services stopped (not changed) by ReviOS CLEANER.ps1: bits, appidsvc, dps, wuauserv (cryptsvc commented out).

## Scheduled Tasks

Mechanism for all: `schtasks /change /tn "<path>" /disable` (ReviOS FINALIZE.cmd) or `Disable-ScheduledTask -TaskPath <dir> -TaskName <name>` / COM `task.Enabled=false` (WH). Revert: `schtasks /change /tn "<path>" /enable`. Task paths below omit the trailing task if the whole folder is meant. Tasks can be re-enabled by cumulative updates (🔁 only where noted). Note: no source in the four inventories defines scheduled-task disables for Xbox, Edge (MicrosoftEdgeUpdateTaskMachineCore/UA), OneDrive (OneDrive Standalone Update Task) or Copilot beyond WindowsAI Recall tasks; those are expected to be removed along with their packages in the edge/appx/ai groups. winutil has no task-disable list.

### task.application-experience
Tasks under `\Microsoft\Windows\Application Experience\`: `AitAgent` (RV), `Microsoft Compatibility Appraiser` (RV,WH,OD), `ProgramDataUpdater` (WH,OD), `MareBackup` (WH,OD), `StartupAppTask` (WH,OD), `PcaPatchDbTask` (OD). ReviOS covers AitAgent and Appraiser only; take the union.
src detail: playbook.md, winhance.md, optimizerduck-revitool.md

### task.ceip
`\Microsoft\Windows\Customer Experience Improvement Program\Consolidator` (RV,WH,OD), `UsbCeip` (RV,WH,OD), `KernelCeipTask` (RV only).
src detail: playbook.md, winhance.md, optimizerduck-revitool.md

### task.wer-queue
`\Microsoft\Windows\Windows Error Reporting\QueueReporting`.
src detail: playbook.md, winhance.md, optimizerduck-revitool.md

### task.disk-diagnostic
`\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector` (RV,WH,OD) and `...\Microsoft-Windows-DiskDiagnosticResolver` (OD).
src detail: playbook.md, winhance.md, optimizerduck-revitool.md

### task.diagnosis-scheduled
`\Microsoft\Windows\Diagnosis\Scheduled` (OD DisableErrorReporting).
src detail: optimizerduck-revitool.md

### task.power-efficiency
`\Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem`.
src detail: playbook.md, winhance.md

### task.memory-diagnostic
`\Microsoft\Windows\MemoryDiagnostic\ProcessMemoryDiagnosticEvents` and `\Microsoft\Windows\MemoryDiagnostic\RunFullMemoryDiagnostic` (RV only).
src detail: playbook.md

### task.feedback-siuf
`\Microsoft\Windows\Feedback\Siuf\DmClient` and `\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload`.
src detail: winhance.md, optimizerduck-revitool.md

### task.sqm
`\Microsoft\Windows\PI\Sqm-Tasks`.
src detail: winhance.md

### task.office
RV: all tasks under `\Microsoft\Office\*` (enumerate with Get-ScheduledTask -TaskPath '\Microsoft\Office\*'). WH: only `\Microsoft\Office\Office Actions Server`. Common tasks: OfficeTelemetryAgentFallBack(2016), OfficeTelemetryAgentLogOn, Office Automatic Updates 2.0, Office Feature Updates (names not in inventories; enumerate at runtime).
src detail: playbook.md, winhance.md

### task.update-orchestrator
RV: `\Microsoft\Windows\UpdateOrchestrator\StartOobeAppsScanAfterUpdate`, `\...\Start Oobe Expedite Work`, `\...\Schedule Scan`. Disabling Schedule Scan stops automatic update scanning (risk med). UpdateOrchestrator tasks are frequently re-enabled by Windows Update (drift). Cross-reference upd group. Revert: enable.
src detail: playbook.md

### task.wu-scheduled-start
`\Microsoft\Windows\WindowsUpdate\Scheduled Start` (listed twice in FINALIZE.cmd). Risk med.
src detail: playbook.md

### task.ucpd-velocity
`\Microsoft\Windows\AppxDeploymentClient\UCPD velocity` (`Disable-ScheduledTask -TaskPath '\Microsoft\Windows\AppxDeploymentClient' -TaskName 'UCPD velocity'`). Companion to svc.ucpd.
src detail: playbook.md

### task.autochk-proxy
`\Microsoft\Windows\Autochk\Proxy` (WH, OD). WH description suggests keeping it for disk health monitoring. Unrelated to perf.disable-autochk (boot-time chkdsk).
src detail: winhance.md, optimizerduck-revitool.md

### task.maps-update
`\Microsoft\Windows\Maps\MapsUpdateTask` (WH,OD).
src detail: winhance.md, optimizerduck-revitool.md

### task.family-safety
`\Microsoft\Windows\Shell\FamilySafetyMonitor` (WH, marked preference).
src detail: winhance.md

### task.windows-ai-recall
`\Microsoft\Windows\WindowsAI\RecallConfiguration` and `\Microsoft\Windows\WindowsAI\RecallPipeline` (WH, Win11 only). Redundant if Recall is removed by the AI group.
src detail: winhance.md

### task.etw-diagnostic-channels
Not a task: `wevtutil sl Microsoft-Windows-SleepStudy/Diagnostic /q:false`, `wevtutil sl Microsoft-Windows-Kernel-Processor-Power/Diagnostic /q:false`, `wevtutil sl Microsoft-Windows-UserModePowerService/Diagnostic /q:false` (FINALIZE.cmd). `%SystemRoot%\System32\SleepStudy` cleaned by perf.disk-cleanup-oneshot. Revert: `/e:true`.
src detail: playbook.md

### task.ngen-run-once
`Get-ScheduledTask -TaskPath "\Microsoft\Windows\.NET Framework\" | Start-ScheduledTask` (ReviOS ngen.ps1): runs the tasks once, leaves them enabled. Also starts SilentCleanup at end of CLEANER.ps1.
src detail: playbook.md

### task.reg-idle-backup
WU WPFFeatureRegBackup: `HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Configuration Manager\EnablePeriodicBackup=1`, `BackupCount=2`; `Register-ScheduledTask 'AutoRegBackup'` daily at 00:30 as SYSTEM running `schtasks /run /i /tn "\Microsoft\Windows\Registry\RegIdleBackup"`. Adds a task instead of removing one. Revert: unregister task, EnablePeriodicBackup=0 or delete.
src detail: winutil-regtweaks.md

## Performance

### perf.win32-priority-separation
`HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl\Win32PrioritySeparation` DWORD=38 (0x26: short, variable quantum, 3:1 foreground boost). RV (ControlSet001), OD, WH ("Programs" option = rec = default 38; "Background Services" = 24). Windows 11 client default is already 2 (0x02) on some builds, 38 on many; set explicitly. Revert: 2.
src detail: playbook.md, optimizerduck-revitool.md, winhance.md

### perf.mmcss-tuning
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile`: SystemResponsiveness DWORD (OD 10, WH 10, default 20), NoLazyMode=1, AlwaysOn=1 (OD only), NetworkThrottlingIndex (see next item). `...\SystemProfile\Tasks\Games`: Priority DWORD (WH 6, OD 2, default 2), "Scheduling Category" SZ="High" (WH,OD; default Medium), "SFIO Priority" SZ="High" (OD), "GPU Priority" DWORD=8 (WH,OD; default 2). Conflict: Priority OD=2 vs WH=6. RV sets none of these except NetworkThrottlingIndex. Revert: SystemResponsiveness=20, Priority=2, Scheduling Category=Medium, GPU Priority=2, delete others.
src detail: optimizerduck-revitool.md, winhance.md, playbook.md

### perf.network-throttling-index
`...\Multimedia\SystemProfile\NetworkThrottlingIndex` DWORD: RV=10 (0xA, Windows default, i.e. leaves throttling on); OD=0xFFFFFFFF (off). Conflict: pick one. Revert: 10.
src detail: playbook.md, optimizerduck-revitool.md

### perf.memory-compression-off
`Disable-MMAgent -mc` (PowerShell, effective after reboot). RV, RT CLI `memory-compression`. Revert: `Enable-MMAgent -mc`.
src detail: playbook.md, optimizerduck-revitool.md

### perf.ntfs-last-access-off
`fsutil behavior set disableLastAccess 1` (RV via `revitool tweaks performance ntfs-last-access disable`). Revert: `fsutil behavior set disableLastAccess 2` (system managed default); RT "enable" writes 0.
src detail: playbook.md, optimizerduck-revitool.md

### perf.ntfs-8dot3-off
`fsutil behavior set disable8dot3 1` (RT: enable = 2). Windows 11 default is 2 (per-volume). Can break very old 16-bit installers. Revert: `fsutil behavior set disable8dot3 2`.
src detail: playbook.md, optimizerduck-revitool.md

### perf.ntfs-memory-usage
`fsutil behavior set memoryusage 2` (high; RT disable = 1). RT only; not applied by ReviOS. Revert: 1.
src detail: optimizerduck-revitool.md

### perf.superfetch-keep
ReviOS revert: `revitool tweaks performance superfetch enable` (SysMain Start=2, rdyboost Start=0, EnablePrefetcher=3, EnableSuperfetch=3 only on HDD per RT). Reason: disabling core Superfetch breaks `defrag c: -b`. This item is the documented "leave alone/restore" action, kept so that a catalog entry can assert default state. Conflicts: svc.sysmain-off, perf.prefetch.
src detail: playbook.md, optimizerduck-revitool.md

### perf.prefetch
`HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters\EnablePrefetcher` DWORD=0 (WH rec=0, default 3); OD also EnableSuperfetch=0. Not applied by ReviOS. Revert: 3.
src detail: winhance.md, optimizerduck-revitool.md

### perf.ifeo-perfoptions
Per-exe `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\<exe>\PerfOptions`: SearchIndexer.exe CpuPriorityClass=5 (BelowNormal); ctfmon.exe CpuPriorityClass=5; fontdrvhost.exe CpuPriorityClass=1 (Idle), IoPriority=0 (VeryLow); lsass.exe CpuPriorityClass=1 (Idle); sihost.exe CpuPriorityClass=1, IoPriority=0. CpuPriorityClass values: 1 Idle, 2 Normal, 3 High, 5 BelowNormal, 6 AboveNormal. RISK: lsass and sihost at Idle priority can cause login lag and shell stalls under CPU load; ReviOS ships it always (RV only). Safer subset: SearchIndexer and ctfmon only. Revert: delete the PerfOptions subkeys.
DECISION (user): implement ONLY SearchIndexer.exe, ctfmon.exe and fontdrvhost.exe. Do NOT write lsass.exe or sihost.exe PerfOptions.
src detail: playbook.md

### perf.shutdown-timeouts
`HKCU\Control Panel\Desktop` (+DEFAULT): AutoEndTasks=1 (SZ), HungAppTimeout=2000 (SZ), WaitToKillAppTimeout=2000 (SZ), LowLevelHooksTimeout=1000 (SZ); `HKLM\SYSTEM\ControlSet001\Control\WaitToKillServiceTimeout=1500` (SZ). Defaults: AutoEndTasks 0, HungAppTimeout 5000, WaitToKillAppTimeout 20000, LowLevelHooksTimeout 3000 (SZ unless absent), WaitToKillServiceTimeout 5000. Can truncate saves at shutdown. RV only.
src detail: playbook.md

### perf.menu-responsiveness
`HKCU\Control Panel\Desktop\MenuShowDelay=0` (SZ; RV,OD,WH rec; winutil visual-effects sets 200; default 400), `ActiveWndTrkTimeout=10` (DWORD; RV only). Plus `HKCU\Control Panel\Mouse\MouseHoverTime` stays 400 (ReviOS reverted lowering). +DEFAULT. Revert: MenuShowDelay=400, delete ActiveWndTrkTimeout.
src detail: playbook.md, optimizerduck-revitool.md, winhance.md

### perf.mouse-hover-time
`HKCU\Control Panel\Mouse\MouseHoverTime` SZ: WH options 1/10/50/100/200/400 ms (rec "1", default 400). ReviOS reverted to 400: lower values caused overlapping tooltips. Do not apply. Revert: "400".
src detail: winhance.md, playbook.md

### perf.keyboard-latency
`HKCU\Control Panel\Keyboard\KeyboardDelay="0"` and `KeyboardSpeed="31"` (SZ). OD sets both; winutil's visual-effects tweak sets only KeyboardDelay=0. Defaults 1 and 31. Revert: KeyboardDelay="1".
src detail: optimizerduck-revitool.md, winutil-regtweaks.md

### perf.disable-accessibility-hotkeys
`HKCU\Control Panel\Accessibility\StickyKeys\Flags="26"`, `...\Keyboard Response\Flags="2"`, `...\ToggleKeys\Flags="34"` (SZ). Defaults 510, 126, 62. OD only. Revert: defaults.
src detail: optimizerduck-revitool.md

### perf.startup-delay
`HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize\StartupDelayInMSec` DWORD=0 (OD; WH rec=0 and offers 10000 as "delay apps by 10 s"). Default key absent (Windows applies ~10 s delay). Revert: delete.
src detail: optimizerduck-revitool.md, winhance.md

### perf.visual-effects
winutil WPFTweaksDisplay: `HKCU\Control Panel\Desktop` DragFullWindows=0 (SZ), MenuShowDelay=200 (SZ), UserPreferencesMask=binary 90 12 03 80 10 00 00 00; `...\Desktop\WindowMetrics\MinAnimate=0` (SZ); `HKCU\Control Panel\Keyboard\KeyboardDelay=0`; `HKCU\...\Explorer\Advanced` ListviewAlphaSelect=0, ListviewShadow=0, TaskbarAnimations=0; `HKCU\...\Explorer\VisualEffects\VisualFXSetting=3`; `HKCU\Software\Microsoft\Windows\DWM\EnableAeroPeek=0`. (Same tweak also sets TaskbarMn=0, ShowTaskViewButton=0, SearchboxTaskbarMode=0: taskbar group.) WH exposes each as a toggle: VisualFXSetting (0 auto, 1 appearance, 2 performance, 3 custom=rec), UserPreferencesMask bits (animate controls, fade/slide menus, tooltips, fade out menu items, shadows under mouse pointer/windows, slide combo boxes, smooth-scroll list boxes: rec 0 = off), MinAnimate="0", TaskbarAnimations=0, EnableAeroPeek (rec 1), AlwaysHibernateThumbnails=0, IconsOnly=0 (thumbnails on), ListviewAlphaSelect=1, DragFullWindows="1", FontSmoothing="2", ListviewShadow=0. Conflicts: winutil turns DragFullWindows and AeroPeek off, WH recommends on. Sign-out required. Revert: WH defaults above.
src detail: winutil-regtweaks.md, winhance.md

### perf.background-apps-off
`HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\GlobalUserDisabled=1`; `HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Search\BackgroundAppGlobalToggle=0`; RT also `HKLM\Software\Policies\Microsoft\Windows\AppPrivacy\LetAppsRunInBackground=2` (WH: HKCU+HKLM policy; 1 force allow, delete = user control). ReviOS reverted (`revitool tweaks performance background-apps enable`, which deletes all three) and clears the `*XboxGamingOverlay*` appx cache: background-app blocking broke the Game Bar Known Game List update. Do not apply. Revert: delete values.
src detail: playbook.md, optimizerduck-revitool.md, winhance.md

### perf.explorer-folder-discovery-off
`HKCU\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell\FolderType` SZ="NotSpecified" (+DEFAULT). winutil additionally deletes `...\Shell\Bags` and `...\Shell\BagMRU` first (loses saved folder views; sign out needed). Revert: delete FolderType (and Bags).
src detail: playbook.md, winutil-regtweaks.md

### perf.explorer-downloads-no-groupby
Clear GroupBy under `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FolderTypes\{885a186e-a440-4ada-812b-db871b942259}` (PowerShell as TrustedInstaller), then as user delete `HKCU\...\Shell\Bags\*\Shell\{885A186E-A440-4ADA-812B-DB871B942259}` to refresh. RV only.
src detail: playbook.md

### perf.explorer-high-perf-gpu
`HKCU\Software\Microsoft\DirectX\UserGpuPreferences` value named `C:\Windows\explorer.exe` (SZ) = `GpuPreference=2;` (+DEFAULT). RV only. Revert: delete value.
src detail: playbook.md

### perf.search-indexing-power
`HKLM\Software\Microsoft\Windows Search\Gather\Windows\SystemIndex\RespectPowerModes=1`; `HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search\PreventIndexOnBattery=1`. RV (explorer/search.yml). Revert: delete.
src detail: playbook.md

### perf.disable-low-disk-checks
`HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\NoLowDiskSpaceChecks=1` (+DEFAULT). RV only. Revert: delete.
src detail: playbook.md

### perf.no-track-shortcuts
`HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer\LinkResolveIgnoreLinkInfo=1`, `NoResolveSearch=1` (+DEFAULT). RV (explorer.yml, start-menu.yml). Revert: delete.
src detail: playbook.md

### perf.disable-autochk
`HKLM\SYSTEM\ControlSet001\Control\Session Manager\BootExecute` MULTI_SZ = `autocheck autochk /k:C*` (excludes C: from boot-time chkdsk; default `autocheck autochk *`). RV, risk med. Revert: `autocheck autochk *`.
src detail: playbook.md

### perf.disable-wpbt
`HKLM\SYSTEM\ControlSet001\Control\Session Manager\DisableWpbtExecution=1`. RV (misc/fixes.yml). Revert: delete.
src detail: playbook.md

### perf.auto-maintenance-off
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance\MaintenanceDisabled=1`; `HKLM\SOFTWARE\Policies\Microsoft\Windows\ScheduledDiagnostics\EnabledExecution=0`. ReviOS option `disable-automatic-maintenance` default OFF; revert deletes both. User explicitly did NOT choose this. Related ReviOS reverts: `HKLM\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction\Enable` and `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OptimalLayout\EnableAutoLayout` deleted (defrag/boot-optimize left default).
src detail: playbook.md

### perf.restore-point-config
Delete key `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SPP\Clients`; `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore\RPSessionInterval=0` and `...\SystemRestore\cfg\DiskPercent=0`. Removes pre-defined config (does not disable System Restore). RV only, risk med. WH separate toggle: `Enable-ComputerRestore -Drive 'C:\'` / `Disable-ComputerRestore -Drive 'C:\'`. Revert: re-enable restore; recreate values.
src detail: playbook.md, winhance.md

### perf.reserved-storage-off
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\ReserveManager\ShippedWithReserves=0` and `Set-WindowsReservedStorageState -State Disabled`. RV (updates.yml, CLEANER.ps1). Windows Update may re-enable. Revert: ShippedWithReserves=1, `-State Enabled`.
src detail: playbook.md

### perf.storage-sense-off
`HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy\01=0` (WU) and WH policy `HKCU` and `HKLM\SOFTWARE\Policies\Microsoft\Windows\StorageSense\AllowStorageSenseGlobal=0` (WH rec=0; on=1; delete=default). Revert: StoragePolicy 01=1, delete policy.
src detail: winutil-regtweaks.md, winhance.md

### perf.long-paths
`HKLM\SYSTEM\CurrentControlSet\Control\FileSystem\LongPathsEnabled=1`. WU (WPFToggleLongPaths and autounattend). Revert: 0.
src detail: winutil-regtweaks.md

### perf.ngen-powershell
ReviOS `ngen.ps1`: ngen install on all loaded PowerShell assemblies for faster startup (one-shot, run via start.yml). Revert: `ngen uninstall` not needed.
src detail: playbook.md

### perf.disk-cleanup-oneshot
RV CLEANER.ps1: `cleanmgr /sagerun:1337` after setting `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\<name>\StateFlags1337=2` for Active Setup Temp Folders, BranchCache, Delivery Optimization Files, Device Driver Packages, Downloaded Program Files, Internet Cache Files, Language Pack, Offline Pages Files, Old ChkDsk Files, Setup Log Files, System error memory dump/minidump files, Temporary Setup Files, Temporary Sync Files, Update Cleanup, Upgrade Discarded Files, User file versions, Windows Defender, WER Files, Windows Reset/Upgrade Log Files; clears all event logs; deletes contents of `%SystemRoot%\{CbsTemp,Logs,SoftwareDistribution,System32\LogFiles(+WMI),System32\SleepStudy,System32\sru,System32\WDI\LogFiles,System32\winevt\Logs,SystemTemp,Temp}`, `%TEMP%` (excluding AME, Revision-Tool), `Program Files (x86)\Microsoft\EdgeUpdate\Download`; starts SilentCleanup task. WU variant: only `Remove-Item %TEMP%\*` and `%SystemRoot%\Temp\*` (WPFTweaksDeleteTempFiles), plus DiskCleanup/component cleanup in Features group. Stop wuauserv/bits first. Not reversible.
src detail: playbook.md, winutil-regtweaks.md

### perf.boot-menu-timeout-0
`bcdedit /set {bootmgr} timeout 0` only when a single OS entry exists. WU autounattend FirstLogon. Revert: `bcdedit /set {bootmgr} timeout 30`.
src detail: winutil-regtweaks.md

### perf.intel-tsx
`HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel\DisableTsx` DWORD: RV enables TSX = 0 (`revitool tweaks performance intel-tsx enable`, ReviOS issue #100); RT disable = 1. Security trade-off (TAA/Zombieload-class). Only meaningful on Intel CPUs with TSX. Reboot. Revert: delete or 1.
src detail: playbook.md, optimizerduck-revitool.md

### perf.svchost-split-ref
Cross-reference only; see svc.svchost-split.
src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md

### perf.power-throttling-off
`HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling\PowerThrottlingOff` DWORD=1 (OD DisablePowerSaving, WH rec=1; default 0/absent). Same setting as pwr.power-throttling-off. OD also sets `HKLM\SYSTEM\CurrentControlSet\Control\USB\AutomaticSurpriseRemoval\AttemptRecoveryFromUsbPowerDrain=0` (see pwr.usb-selective-suspend). Reboot. Revert: 0 or delete.
src detail: optimizerduck-revitool.md, winhance.md

### perf.hags
`HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\HwSchMode` DWORD: 2 = on, 1 = off (OD, WH rec=2). ReviOS has `HwSchMode=2` commented out in win-settings.yml because a user had HW acceleration issues; do not force. Reboot. Revert: delete (driver default).
src detail: optimizerduck-revitool.md, winhance.md, playbook.md

### perf.mpo-off
`HKLM\SOFTWARE\Microsoft\Windows\Dwm\OverlayTestMode` DWORD=5 (off; delete = on) (WU,WH,RT `swapchain-mpo`). Extras from WH/WU: `HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\DisableOverlays=1` (breaks Steam/Discord overlays; WU same), `HKLM\SOFTWARE\Microsoft\Windows\Dwm\OverlayMinFPS=0` (stuttering fix, less invasive). Reboot. Use only for flicker/stutter on multi-monitor/high-refresh. Revert: delete each.
src detail: winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md

### perf.directx-windowed-flip
`HKCU\Software\Microsoft\DirectX\UserGpuPreferences\DirectXUserGlobalSettings` SZ semicolon-separated tokens: WH "Optimizations for windowed games" rec "1"/on (token-style `SwapEffectUpgradeEnable=1;`), RT `swapchain-wo` prepends `SwapEffectUpgradeEnable=0;` (disable) or `=1;` (enable) stripping the opposite. WH also writes `VRROptimizeEnable=` and `AutoHDREnable=` into the same string (see game.auto-hdr-vrr); merge tokens, do not overwrite. Windows default enabled. Revert: `SwapEffectUpgradeEnable=1;`.
src detail: winhance.md, optimizerduck-revitool.md

### perf.gpu-nvidia
Under the display class key `HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}\<NNNN>` (NNNN = 4-digit instance for the NVIDIA adapter; OD maps WMI Win32_VideoController DeviceID "VideoControllerN" to N-1): `DisableDynamicPstate=1` (low risk), `DisableASyncPstates=1` (med). Vendor-detect first. Higher idle power/heat. Reboot. Revert: delete values.
src detail: optimizerduck-revitool.md

### perf.gpu-amd
Same display class subkey for the AMD adapter: `EnableULPS=0`; `DisablePowerGating=1`, `PP_GPUPowerDownEnabled=0`, `DisableDynamicPstate=1` (med); `DisableVCEPowerGating=1`, `DisableVceClockGating=1`, `EnableUvdClockGating=0`, `EnableVceSwClockGating=0` (med); `EnableAspmL0s=0`, `EnableAspmL1=0`. OD lists these as four separate tweaks; collapsed here. Reboot. Revert: delete values.
src detail: optimizerduck-revitool.md

### perf.gpu-intel
Same display class subkey for the Intel adapter: `Display1_DisableAsyncFlips=1`, `AdaptiveVsyncEnable=0`. Reboot. Revert: delete values.
src detail: optimizerduck-revitool.md

### perf.search-webview2
WH "WebView2 in Windows Search" (off): `HKLM\SYSTEM\CurrentControlSet\Control\FeatureManagement\Overrides\8\1694661260` EnabledState=1 (off; on=2), EnabledStateOptions=0, Variant=0 (further sibling values truncated in inventory, consult winhance.md line ~203 if needed). Undocumented feature ID; may be reverted by updates. Removes Edge processes spawned by SearchHost.exe.
src detail: winhance.md

### perf.alt-tab-filter
`HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\MultiTaskingAltTabFilter` DWORD=3 (windows only; 0 = include Edge tabs; WH default shows 3). WH only.
src detail: winhance.md

### perf.webdav-limit
`HKLM\SYSTEM\CurrentControlSet\Services\WebClient\Parameters\FileSizeLimitInBytes` DWORD=0xFFFFFFFF (default 50000000). OD only. Revert: 50000000.
src detail: optimizerduck-revitool.md

### perf.wallpaper-quality
`HKCU\Control Panel\Desktop\JPEGImportQuality` DWORD=100 (WH rec=100; "on"=0/absent default 85%). Stops lossy wallpaper recompression. Revert: delete.
src detail: winhance.md

### perf.copy-dialog-details
`HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\OperationStatusManager\EnthusiastMode=1` (+DEFAULT). RV only. Revert: delete.
src detail: playbook.md

### perf.search-whole-filesystem
`HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Search\Preferences\WholeFileSystem` DWORD=1 (WH rec=0; default 0). Listed to record WH's recommendation against it. Revert: 0.
src detail: winhance.md

## Gaming

### game.gamedvr-off
Union: `HKCU\System\GameConfigStore\GameDVR_Enabled=0` (RV +DEFAULT, WH, OD), `HKCU\System\GameConfigStore\GameDVR_HistoricalCaptureEnabled=0` (OD), `HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR\AppCaptureEnabled=0` (WU,WH,OD; RV only if Xbox appx removed, otherwise ReviOS reverted/deleted it because the Start Recording button was greyed, issue #74), `HistoricalCaptureEnabled=0` (OD), `HKLM\SOFTWARE\Policies\Microsoft\Windows\GameDVR\AllowGameDVR=0` (WH,OD). RV deletes `HKLM\...\GameDVR\AppCaptureEnabled`. Revert: GameDVR_Enabled=1, AppCaptureEnabled=1, delete policy.
src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md

### game.gamebar-off
`HKCU\System\GameConfigStore\GameBarEnabled=0` (OD); `HKCU\Software\Microsoft\GameBar` ShowStartupPanel=0 (WH rec 0), UseNexusForGameBarEnabled=0 (WH rec, OD), GamePanelStartupTipIndex=0 (OD, optional). Revert: delete or 1.
src detail: optimizerduck-revitool.md, winhance.md

### game.game-mode
`HKCU\Software\Microsoft\GameBar` AllowAutoGameMode=1, AutoGameModeEnabled=1 (WU, OD both; WH only AutoGameModeEnabled). Windows default is on. Revert: 0 or delete.
src detail: winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md

### game.fullscreen-optimizations-off
`HKCU\System\GameConfigStore`: OD disable = GameDVR_DXGIHonorFSEWindowsCompatible=1, GameDVR_FSEBehavior=2, GameDVR_FSEBehaviorMode=2, GameDVR_HonorUserFSEBehaviorMode=1 (default 0); RT `swapchain-fso` writes the same under HKCU and `HKU\.DEFAULT\System\GameConfigStore` plus GameDVR_EFSEFeatureFlags=0; enable deletes the extras and sets FSEBehaviorMode=0. WH: GameDVR_FSEBehaviorMode rec=0 (FSO on), off=2. RV sets GameDVR_FSEBehaviorMode=0 (final.yml). Conflict: RV keeps FSO on while OD disables. Revert: GameDVR_FSEBehaviorMode=0, delete others.
src detail: playbook.md, winhance.md, optimizerduck-revitool.md

### game.mouse-accel-off
`HKCU\Control Panel\Mouse` (+DEFAULT): MouseSpeed="0", MouseThreshold1="0", MouseThreshold2="0" (SZ). "On" = 1/6/10 (default). RV,WU,WH,OD. Revert: MouseSpeed="1", Threshold1="6", Threshold2="10".
src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md

### game.raw-mouse-throttle
RT `background-window-message-rate-limit`: `HKCU\Control Panel\Mouse\RawMouseThrottleEnabled=1`, `RawMouseThrottleDuration=<3..20>` (ms; rate = 1000/duration). Revert: delete.
src detail: optimizerduck-revitool.md

### game.vbs-hvci-off
Same as sec.vbs-hvci-off (security group owns the mechanism). For reference RV: `revitool tweaks security vbs disable` (also disables HVCI); RT: `bcdedit /set vsmlaunchtype off`; `HKLM\SOFTWARE\Policies\Microsoft\Windows\DeviceGuard` EnableVirtualizationBasedSecurity=0, LsaCfgFlags=0, HVCIMATRequired=0; `HKLM\SYSTEM\ControlSet001\Control\DeviceGuard` EnableVirtualizationBasedSecurity=0 ... (see optimizerduck-revitool.md Security). ReviOS comment: "improves gaming perf". Reboot.
src detail: playbook.md (Gaming/Security), optimizerduck-revitool.md

### game.gaming-copilot-block
`HKLM\SOFTWARE\Microsoft\WindowsRuntime\ActivatableClassId\Microsoft.Xbox.GamingAI.Companion.Host.GamingCompanionHostOptions`: ActivationType=4294967295 (0xFFFFFFFF), Server="" (SZ). RV (privacy.yml). Revert: delete values.
src detail: playbook.md

### game.gpu-priority-games
Games task keys under `HKLM\Software\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games`: GPU Priority=8, Priority=6 (WH; OD 2), Scheduling Category="High" (SZ). Shared with perf.mmcss-tuning; apply once. Revert: GPU Priority=2, Priority=2, Scheduling Category="Medium".
src detail: winhance.md, optimizerduck-revitool.md

### game.auto-hdr-vrr
`HKCU\Software\Microsoft\DirectX\UserGpuPreferences\DirectXUserGlobalSettings` (SZ tokens): VRR optimizations (WH rec "0" off, on=1, default 1) and Auto HDR (WH rec "0", default 0, Win11 only). Merge tokens with perf.directx-windowed-flip.
src detail: winhance.md

### game.auto-color-management
`HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\MonitorDataStore\AutoColorManagementEnabled` DWORD (WH rec 0, default 0, on=1; Win11 only). Reboot.
src detail: winhance.md

### game.desktop-composition-off
`HKCU\Software\Microsoft\Windows\DWM\CompositionPolicy` DWORD=0 (off; delete = on). WH only; breaks Aero/transparency; Win11 DWM generally ignores. Revert: delete.
src detail: winhance.md

### game.nvidia-extras
`HKLM\Software\NVIDIA Corporation\Global\FTS\EnableGR535` DWORD (WH: rec 0 = enable legacy sharpening, default 1); `HKLM\SOFTWARE\NVIDIA Corporation\Global\NGXCore\ShowDlssIndicator` DWORD (OD: 0 off, 1 debug-only, 1024 all). NVIDIA-only. ReviOS privacy item for NVIDIA telemetry (`HKCU\Software\NVIDIA Corporation\NVControlPanel2\Client\OptInOrOutPreference=0`) is in priv group. Revert: EnableGR535=1, delete ShowDlssIndicator.
src detail: winhance.md, optimizerduck-revitool.md, playbook.md

### game.known-game-list-refresh
RT `updates kgl`: GET `https://settings.data.microsoft.com/settings/v3.0/xbox/knowngamelist`; write `HKCU\Software\Microsoft\Windows\CurrentVersion\GameDVR\KGLRevision`, `KGLToGCSUpdatedRevision`; `HKLM\SOFTWARE\Microsoft\KGL\OneSettings` ActivateOnUpdate, Hash, URI, Version, VersionCheckTimeout; re-enables background apps. Relevant if GameDVR/Game Bar kept. Requires network call (contradicts privacy goals).
src detail: optimizerduck-revitool.md

### game.per-game-mitigations
`HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\vgc.exe` (Valorant): MitigationOptions BINARY `000000000001000000000000000000000000000000000000` (CFG), MitigationAuditOptions BINARY zeros, EAFModules SZ ""; `...\osu!.exe`: MitigationOptions `000021000000000000000000000000000000000000000000` (ASLR), MitigationAuditOptions zeros, EAFModules "". RV only. Revert: delete subkeys.
src detail: playbook.md

### game.boot-timer-defaults
ReviOS FINALIZE.cmd: `bcdedit /deletevalue useplatformclock`, `bcdedit /deletevalue disabledynamictick` (reset to default). The lines `bcdedit /set useplatformtick yes` and `disabledynamictick yes` are commented out in ReviOS: break ROG Ally sleep (issue #167). Reboot.
src detail: playbook.md

### game.teredo-off
WU WPFTweaksTeredo (defined in the network group; see net.* for mechanism: registry `HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters\DisabledComponents` and netsh teredo state disabled). Cross-reference only.
src detail: winutil-regtweaks.md (Gaming, Network)

### game.vulnerable-driver-blocklist
ReviOS keeps `HKLM\SYSTEM\CurrentControlSet\Control\CI\Config\VulnerableDriverBlocklistEnable=1` (setting 0 breaks THE FINALS anti-cheat); also deleted: process mitigation policy keys `HKCU+HKLM\SOFTWARE\Policies\Microsoft\Windows NT\MitigationOptions\ProcessMitigationOptions` and Memory Management `FeatureSettings`, `FeatureSettingsOverride`, `FeatureSettingsOverrideMask` (Spectre/Meltdown mitigations restored). Documents "do not weaken" state; mostly security group.
src detail: playbook.md

## Power

### pwr.hibernate-off
User-chosen [x]. RV: `revitool tweaks utilities hibernation disable` + `revitool tweaks utilities fast-startup disable` (ReviOS option `disable-hibernate`, default; radio with `enable-hibernate`). Equivalent commands: `powercfg -h off`; `HKLM\SYSTEM\ControlSet001\Control\Power\HibernateEnabled=0`; `HKLM\SYSTEM\ControlSet001\Control\Session Manager\Power\HiberbootEnabled=0`; `HKLM\Software\Policies\Microsoft\Windows\System\ShowHibernateOption=0` (RT) and/or `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings\ShowHibernateOption=0` (WU; WH rec 0); `HKLM\Software\Policies\Microsoft\Windows\System\HiberbootEnabled=0` (RT). OD uses the native power API (PowerProf SystemReserveHiberFile) and records prior state. Laptops: sleep may overheat per ReviOS UI warning; deletes hiberfil.sys. Revert: `powercfg -h on` (RT `powercfg /h /type full`), HibernateEnabled=1, HiberbootEnabled=1, ShowHibernateOption=1.
src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md

### pwr.fast-startup-off-only
`HiberbootEnabled=0` at `HKLM\System\ControlSet001\Control\Session Manager\Power` and `HKLM\Software\Policies\Microsoft\Windows\System` (RT `fast-startup disable`; WH rec 0, on=delete). RT's "enable" also turns hibernation back on. Redundant with pwr.hibernate-off.
src detail: optimizerduck-revitool.md, winhance.md

### pwr.high-performance-plan
ReviOS `revitool tweaks performance powerplan enable`: `powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 6a93ec26-284d-4943-9fc4-c9616def55c6`; rename to "Revision - Ultra Performance"; `powercfg -s 6a93ec26-...`; delete scheme 3ff9831b-6f80-4830-8178-736cd4229e7b; then (TrustedInstaller) write `ACSettingIndex` (DWORD) under `HKLM\SYSTEM\ControlSet001\Control\Power\User\PowerSchemes\6a93ec26-284d-4943-9fc4-c9616def55c6\54533251-82be-4824-96c1-47b60b740d00\`: 465e1f50-b610-473a-ab58-00d1077dc418 (PERFINCPOL)=2, 40fbefc7-2e9d-4d25-a185-0cfd8574bac6 (PERFDECPOL)=1, 06cadf0e-64ed-448a-8927-ce7bf90eb35d (increase threshold)=10, 12a0ab44-fe28-4fa9-b3bd-4b64f44960a6 (decrease threshold)=8, 0cc5b647-c1df-4637-891a-dec35c318583 and 0cc5b647-...584 (core parking min cores, P/E classes)=100; and `...\2a737441-1930-4402-8d77-b2bebba308a3\d4e98f31-5ffe-4ce1-be31-1b38b384c009\ACSettingIndex=0` (USB3 link power mgmt off); then `powercfg /setactive scheme_current`. Disable: activate Balanced 381b4222-f694-41f0-9685-ff5bb260df2e then `powercfg -delete 6a93ec26-...`. WU variant: `powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61` then set active (WPFAddUltPerf, "NOT FOR LAPTOPS"); remove with `powercfg -delete <guid>` (WPFRemoveUltPerf). WH plan selector GUIDs: Power Saver a1841308-3541-4fab-bc81-f71556f20b4a, Balanced 381b4222-f694-41f0-9685-ff5bb260df2e, High performance 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c, Ultimate e9a42b02-d5df-448d-aa00-03f14749eb61 (via `powercfg /duplicatescheme` + `/setactive`). optimizerDuck imports a bundled `optimizerDuck.pow` (embedded resource) and activates it, remembering the previous plan GUID; ITS CONTENTS ARE NOT CAPTURED in the inventory, so it cannot be reproduced from here. Ultimate Performance is unavailable on some Modern Standby laptops until the scheme is exposed via duplicatescheme.
src detail: playbook.md, winutil-regtweaks.md, winhance.md, optimizerduck-revitool.md

### pwr.plan-c6-disable
RT `powerplan-states-c6`, inside the Revi plan: idle promote `7b224883-b3cc-4d79-819f-8374152cbe7c` ACSettingIndex=100 and demote `4b92d758-5a24-4851-a470-815d78aee119`=80 (C6 disabled); enabled = 60/40 and delete `HKLM\SYSTEM\ControlSet001\Control\Processor\Capabilities`. Under subgroup 54533251-82be-4824-96c1-47b60b740d00 of the same scheme path. Depends on pwr.high-performance-plan.
src detail: optimizerduck-revitool.md

### pwr.display-sleep-timeouts
Via `powercfg /setacvalueindex` / `/setdcvalueindex` (values in seconds; WH "RecommendedValue" AC/DC, "Default" AC/DC): display off SUB_VIDEO/VIDEOIDLE rec 0/300 (default 300/180); disk off SUB_DISK/DISKIDLE rec 0/600 (default 1200/600); sleep SUB_SLEEP/STANDBYIDLE rec 0/900 (default 900/600); wake timers SUB_SLEEP/RTCWAKE rec 0/0 (default 1/1) (disables RTC wake timers; may stop scheduled wake tasks). Interactive prompts per plan. Apply to the active plan.
src detail: winhance.md

### pwr.usb-selective-suspend
WH: USB selective suspend (SUB_USB, GUID 2a737441-1930-4402-8d77-b2bebba308a3 / 48e6b7a6-50f5-4782-a5d4-53bb8f07e226) rec AC 0 / DC 1 (default 1/1); USB hub selective suspend timeout (0853a681-27c8-4100-a2fd-82013e970683) rec 0 AC / 1000 DC (default 50/50); USB3 link power management (d4e98f31-5ffe-4ce1-be31-1b38b384c009) rec 0 / 2 (default 2/2). WH also writes `...\PowerSettings\<sub>\<setting>\Attributes=0` DWORD to unhide each in the Power Options UI. RV: sets USB3 LPM ACSettingIndex=0 inside the Revision plan. OD: per-device WMI `MSPower_DeviceEnable` false on every USB instance (reverts per instance) plus `HKLM\SYSTEM\CurrentControlSet\Control\USB\AutomaticSurpriseRemoval\AttemptRecoveryFromUsbPowerDrain=0`. Revert: defaults above.
src detail: winhance.md, optimizerduck-revitool.md, playbook.md

### pwr.pcie-aspm-off
`powercfg` SUB_PCIEXPRESS (501a4d13-42af-4429-9fd1-a8218c268e20) / ASPM (ee12f906-d277-404b-b6da-e5fa1a576df5): WH rec AC 0 (off) / DC 2 (default 1/2). OD's AMD tweak also disables ASPM in the driver (perf.gpu-amd). Revert: AC 1, DC 2.
src detail: winhance.md

### pwr.processor-states
Subgroup SUB_PROCESSOR 54533251-82be-4824-96c1-47b60b740d00, WH rec (AC/DC) vs default: PROCTHROTTLEMIN 100/5 (default 0/5); PROCTHROTTLEMAX 100/100; cooling policy (94d3a615-...) 1/1 (default 1/0); PERFBOOSTMODE (be337238-...) 2/1 (default 2/?); PERFINCPOL (465e1f50-...) 2/0 (default 2/?; RV plan 2); PERFDECPOL (40fbefc7-...) 1/2 (default 1/?; RV plan 1); CPMINCORES (0cc5b647-...) 0/0 (default 100/10; RV plan 100); CPMAXCORES (ea062031-...) 100/100; PERFEPP (36687f9e-...) 0/50; PERFINCTHRESHOLD (06cadf0e-...) 10/? (RV 10); PERFDECTHRESHOLD (12a0ab44-...) 8/? (RV 8). Conflict: WH recommends CPMINCORES 0 (core parking allowed) while RV plan sets 100 (parking off). WH values for DC thresholds are truncated in the inventory. Each also needs `Attributes=0` under `HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\<sub>\<setting>` to show in the UI.
src detail: winhance.md, optimizerduck-revitool.md

### pwr.power-throttling-off
Same registry value as perf.power-throttling-off: `HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling\PowerThrottlingOff=1`. Apply once. Reboot.
src detail: optimizerduck-revitool.md, winhance.md

### pwr.sleep-states
`HKLM\System\CurrentControlSet\Control\Power\PlatformAoAcOverride=0` DWORD (disable Modern Standby S0 so S3 is used; WU `WPFToggleS3Sleep`, RT `modern-standby`; delete to restore; high risk: hardware must support S3, ROG-class handhelds break). WU also: `HKCU\SOFTWARE\Policies\Microsoft\Power\PowerSettings\f15576e8-98b7-4186-b944-eafa664402d9\ACSettingIndex=1` (S0 network connectivity during standby). Reboot.
src detail: winutil-regtweaks.md, optimizerduck-revitool.md

### pwr.hybrid-sleep-hibernate-timeouts
SUB_SLEEP HYBRIDSLEEP rec 0/0 (default 1/1); HIBERNATEIDLE rec 0/0 (default AC 0 / DC 10800). Moot when hibernation is off.
src detail: winhance.md

### pwr.button-lid-actions
SUB_BUTTONS (4f971e89-eebd-4455-a8de-9e59040e7347): power button (7648efa3-dd9c-4e3e-b566-50f929386280, rec 0 = do nothing, default 3 = shutdown), sleep button (96996bc0-ad50-47ec-923b-6f41874dd9eb, rec 0, default 1), lid close (LIDACTION 5ca83367-6e45-459f-a27b-476b1d01c936, rec AC 1 / DC 1, default 1/1). Plus unhide via Attributes=0. User picks actual actions.
src detail: winhance.md

### pwr.start-power-menu
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings`: ShowSleepOption=1 (RV, WH), ShowLockOption (WH), ShowHibernateOption (see pwr.hibernate-off). Revert: delete.
src detail: playbook.md, winhance.md

### pwr.shutdown-without-logon
`HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\ShutdownWithoutLogon=1`. RV only. Revert: 1 is the default on client; delete.
src detail: playbook.md

### pwr.logon-polish
`HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System`: EnableFirstLogonAnimation=0, DisableStartupSound=1. RV (logon.yml). Revert: 1 / 0.
src detail: playbook.md

### pwr.crash-control
`HKLM\SYSTEM\ControlSet001\Control\CrashControl`: AutoReboot=0, CrashDumpEnabled=3 (small memory dump). RV (crash-control.yml). Revert: AutoReboot=1, CrashDumpEnabled=7 (automatic).
src detail: playbook.md

### pwr.gpu-power-plan-settings
WH powercfg-only settings (AC/DC rec vs default): Intel graphics power plan 2/1 (default 1/1); AMD power slider overlay 3/1 (default 2/2); ATI PowerPlay 2/1 (default 1/1); switchable graphics GPU preference 2/1 (default 1/1). GUIDs not in inventory. Hardware-specific.
src detail: winhance.md

### pwr.multimedia-battery
WH powercfg values (AC/DC rec vs default): when sharing media 1/1 (default 1/0); video playback quality bias 1/1 (default 1/0); when playing video 0/0 (default 0/1); JavaScript timer frequency 0/0 (default 0/1); desktop slideshow 1/1 (default 0/1); wireless adapter power saving 0/2 (default 0/2). Mostly laptop relevant.
src detail: winhance.md

### pwr.battery-levels
WH SUB_BATTERY: BATLEVELLOW 10/10, BATLEVELCRIT 5/5, BATFLAGSLOW 1/1, BATFLAGSCRIT 1/1, BATACTIONLOW 0/0 (do nothing), BATACTIONCRIT 2/2 (hibernate; note hibernate off changes this to shutdown), reserve level 7/7. All equal to defaults. Laptops only.
src detail: winhance.md

### pwr.battery-percentage-tray
`HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\IsBatteryPercentageEnabled=1`. OD only.
src detail: optimizerduck-revitool.md

### pwr.hello-logon-fix
Delete `HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System\DisableAutomaticRestartSignOn` (ReviOS revert; fixes slow Windows Hello logon). Defender signature-update-on-battery policy `HKLM\Software\Policies\Microsoft\Windows Defender\Signature Updates\DisableScheduledSignatureUpdateOnBattery=1` is also listed by RV in Power but belongs to sec/Defender.
src detail: playbook.md
