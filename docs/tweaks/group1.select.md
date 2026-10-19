## Privacy & Telemetry

- [ ] **priv.telemetry-policy** — Telemetry level 0 (policy + CPSS): sets AllowTelemetry=0 in every policy/CPSS/PolicyManager location · risk: low · src: RV,RT,OD,WU,WH · rec: ✅ · ♻ · Home/Pro still send Required data; 0 acts as the minimum.
- [ ] **priv.datacollection-hardening** — DataCollection policy hardening: commercial pipeline, device name, feedback/opt-in UX, flighting, dump/log limits off · risk: low · src: RV,RT,OD,WH · rec: ✅ · · Companion to priv.telemetry-policy.
- [ ] **priv.autologgers-off** — Telemetry ETW autologgers off: Diagtrack-Listener, SQMLogger and others set Start=0 · risk: low · src: RV,OD · rec: ✅ · 🔒 · RV disables 3 sessions; OD disables 10 (more aggressive, med risk).
- [ ] **priv.appcompat-policy** — Application Compatibility telemetry off: engine, inventory, PCA, steps recorder, program telemetry · risk: med · src: RV,OD,WH · rec: ✅ · · DisableEngine=1 can stop legacy compat shims; OD/WH only set AITEnable/DisableInventory.
- [ ] **priv.ceip-off** — Customer Experience Improvement Program / SQM disabled (Windows, App-V, IE, Messenger) · risk: low · src: RV · rec: ✅ · ·
- [ ] **priv.content-delivery-off** — Content Delivery Manager off: silent app installs, tips, suggestions, lock-screen spotlight/fun facts · risk: low · src: RV,OD,WH,WU · rec: ✅ · 👤 · Also deletes Subscriptions and SuggestedApps keys.
- [ ] **priv.cloudcontent-policies** — CloudContent/Spotlight policies: soft landing, third-party suggestions, cloud-optimized content, Spotlight, Settings ads · risk: low · src: RV,OD,WU · rec: ✅ · 👤 · Excludes DisableWindowsConsumerFeatures (see priv.consumer-features-policy).
- [ ] **priv.consumer-features-policy** — DisableWindowsConsumerFeatures=1 (stops promoted app installs) · risk: med · src: OD,WU · rec: ⛔ · · ReviOS deliberately does NOT set it: breaks Your Phone/Phone Link. Conflicts with priv.cloudcontent-policies intent.
- [ ] **priv.restrict-internet-comm** — Restrict Internet communication policies: publishing wizard, web services, online prints, HTTP printing, PCHealth, registration wizard · risk: low · src: RV · rec: ✅ · 👤 · Many HKCU+HKLM values.
- [ ] **priv.error-reporting-off** — Windows Error Reporting disabled (policy, consent, dumps) plus handwriting error reports · risk: low · src: RV,OD,WH · rec: ✅ · · WerSvc/PcaSvc service handling lives in svc group.
- [ ] **priv.firewall-telemetry-block** — Outbound firewall rules blocking DiagTrack and WerSvc svchost to the Internet · risk: low · src: RV · rec: ✅ · 🔒 · Do NOT add the Windows-Insider (wisvc) rule: breaks Xbox. Firewall itself is otherwise left on.
- [ ] **priv.hosts-telemetry-blocklist** — Replace hosts file with ~50 Microsoft telemetry/Watson/ads hosts (and Brave/VS telemetry) to 0.0.0.0 · risk: low · src: RV · rec: ✅ · · Overwrites whole hosts file; consider merging instead.
- [ ] **priv.hosts-adobe-block** — Append Ruddernation Adobe telemetry/activation URL blocklist to hosts · risk: med · src: WU · rec: ⚠️ · · External download; can break Adobe activation/licensing.
- [ ] **priv.ifeo-telemetry-exes** — IFEO Debugger=taskkill for CompatTelRunner, AggregatorHost, DeviceCensus, FeatureLoader, BingChatInstaller, BGAUpsell, BCILauncher · risk: med · src: RV · rec: ➕ · 🔒🔁 · CompatTelRunner also drives upgrade-compat scans.
- [ ] **priv.advertising-id-off** — Advertising ID disabled (user, machine, policy; Id deleted) · risk: low · src: RV,OD,WH,WU · rec: ✅ · 👤 ·
- [ ] **priv.tailored-diagnostics-feedback** — Tailored experiences, diagnostic transcript viewer, feedback prompts (SIUF) off, DoNotShowFeedbackNotifications · risk: low · src: RV,OD,WH,WU · rec: ✅ · 👤 ·
- [ ] **priv.activity-history-off** — Activity history/timeline: feed, publish and upload user activities off · risk: low · src: RV,OD,WU · rec: ✅ · · WU sets EnableActivityFeed=1 (likely source bug); use 0.
- [ ] **priv.input-personalization-off** — Inking/typing/contact harvesting, TIPC, HttpAcceptLanguageOptOut off · risk: low · src: RV,RT,OD,WH,WU · rec: ✅ · 👤 · RT verb `input-personalization disable`; clears custom dictionary.
- [ ] **priv.online-speech-narrator** — Online speech recognition and Narrator cloud services/scripting off · risk: low · src: RV,OD,WH,WU · rec: ➕ · 👤 · Disabling online speech removes cloud dictation.
- [ ] **priv.capability-consent-deny** — App capability ConsentStore=Deny for account info, calendar, tasks, chat, radios, bluetoothSync, diagnostics, libraries, filesystem · risk: med · src: RV,WH · rec: ✅ · 👤 · Contacts/email/call history left alone (Mail&Calendar). broadFileSystemAccess Deny can break some UWP apps.
- [ ] **priv.location-sensors-off** — Location and sensors off: ConsentStore, LocationAndSensors policy, Maps auto-update, lfsvc, Geolocation · risk: med · src: RV,OD,WH,WU · rec: ✅ · 👤 · Breaks maps/weather auto-location and Find My Device. lfsvc handled in svc group.
- [ ] **priv.camera-mic-access** — Camera/microphone ConsentStore Allow (or Deny) · risk: med · src: RV,WH · rec: ➕ · 👤 · ReviOS explicitly sets Allow; Deny breaks calls. Preference toggle.
- [ ] **priv.find-my-device-off** — Find My Device policy disabled · risk: low · src: OD · rec: ➕ · ·
- [ ] **priv.wifi-sense-off** — Wi-Fi Sense/hotspot reporting and auto-connect to suggested hotspots off · risk: low · src: RV,OD,WH · rec: ✅ · ·
- [ ] **priv.settings-sync-off** — Windows Settings Sync categories disabled by policy (user override allowed) · risk: low · src: RV · rec: ✅ · · Breaks cross-device sync of themes/passwords/language.
- [ ] **priv.cloud-messaging-misc** — Message cloud sync, EdgeUI help sticker, MFU tracking, NVIDIA control panel telemetry opt-out · risk: low · src: RV,OD · rec: ✅ · 👤 ·
- [ ] **priv.feature-advert-tips** — Balloon feature adverts, online tips, cloud app notifications, Scoobe/finish-setup nags, suggestion toasts off · risk: low · src: RV,OD,WH,WU · rec: ✅ · 👤 ·
- [ ] **priv.start-tracking-off** — Start menu tracking: Start_TrackProgs/TrackDocs, recommendations, account notifications · risk: low · src: OD,WH,WU · rec: ➕ · 👤 · May overlap start group; keep one.
- [ ] **priv.search-cloud-history** — Search history, search highlights, MSA/AAD cloud search, Cortana policy off · risk: low · src: WH · rec: ➕ · 👤 · Bing-in-Start (BingSearchEnabled) belongs to start group.
- [ ] **priv.mrt-reporting-off** — Malicious Software Removal Tool infection reporting off · risk: low · src: RV · rec: ✅ · ·
- [ ] **priv.valuebanner-off** — Disable Settings value banner ads (ActivatableClassId ValueBanner) · risk: low · src: RV · rec: ✅ · 🔒 ·
- [ ] **priv.dev-telemetry-env** — DOTNET_CLI_TELEMETRY_OPTOUT and POWERSHELL_TELEMETRY_OPTOUT machine env vars · risk: low · src: RV,WU · rec: ✅ · ·
- [ ] **priv.winget-telemetry-off** — winget settings.json telemetry.disable for default user and existing profiles · risk: low · src: RV · rec: ✅ · 👤 · RV ties it to remove-pinned-items option.
- [ ] **priv.office-telemetry-off** — Office ClickToRun log management/timer and all \Microsoft\Office\* scheduled tasks disabled · risk: low · src: RV · rec: ➕ · · Cross-ref task group.
- [ ] **priv.rsop-logging-off** — Resultant Set of Policy logging off · risk: low · src: RV · rec: ➕ · ·
- [ ] **priv.usage-reporting-off** — Usage reporting: DPS/diagsvc/WDI services, SleepStudy and power diagnostic logs off · risk: med · src: RT · rec: ➕ · 🔒 · Services overlap svc group; DPS off hides some troubleshooters.
- [ ] **priv.device-metadata-network-off** — Prevent device metadata/companion apps download from network · risk: low · src: RT,WU · rec: ➕ · · Also listed under upd.drivers-wu-off in RT.
- [ ] **priv.wpbt-off** — Disable Windows Platform Binary Table execution (OEM firmware-injected exes) · risk: med · src: WU · rec: ➕ · ♻ · May break OEM anti-theft/bloat tools.
- [ ] **priv.store-recommendations-block** — Deny ACL on Store store.db to stop recommended search results · risk: med · src: WU · rec: ⛔ · 🔁 · Hacky, locks Store DB; Store updates may fail.
- [ ] **priv.telemetry-removal-package** — Remove telemetry components via revitool winpackage telemetry-removal (WinSxS) · risk: high · src: RV · rec: ⛔ · · Opaque Revision signed package; not reproducible. Servicing-stack removal.
- [ ] **priv.oosu-external** — Launch O&O ShutUp10++ with a config · risk: med · src: WU · rec: ⛔ · · External software; redundant with items here.

## Security

- [x] **sec.defender-disable** — Disable Windows Defender (policy flags, core keys, MDCoreSvc off, definitions removed) · risk: high · src: RV,RT · rec: ⚠️ · 🔒♻ · Tamper Protection must be off first; Jan-2026 updates strip policy value on gpupdate. See mech.
- [ ] **sec.defender-remove-package** — Install Revision-ReviOS-Defender-Removal CBS package to remove Defender components · risk: high · src: RV,RT · rec: ⛔ · 🔒 · Needs Revision's signed CAB; not reproducible. Optional extra over sec.defender-disable.
- [ ] **sec.defender-ui-hide** — Hide Defender systray, remove SecurityHealth Run entry, silence Security Center notifications · risk: low · src: RV,WH · rec: ✅ · · Pairs with sec.defender-disable.
- [ ] **sec.defender-reporting** — Defender cloud reporting: generic reports off, sample submission never, battery signature updates off · risk: low · src: RV,WU · rec: ➕ · · Redundant when Defender disabled; useful if Defender kept.
- [ ] **sec.smartscreen-off** — SmartScreen off: app install control, web content evaluation, Edge phishing filter · risk: med · src: RV,RT · rec: ✅ · 👤🔁 · RT also renames smartscreen.exe to .revi and sets IFEO inside Defender flow.
- [ ] **sec.smart-app-control-off** — Smart App Control Off (VerifiedAndReputablePolicyState=0) · risk: high · src: WH · rec: ➕ · ♻ · One-way: once Off, cannot be re-enabled without reinstall. Fresh installs start in evaluation.
- [ ] **sec.vbs-off** — Disable Virtualization-Based Security (bcdedit vsmlaunchtype off, DeviceGuard policy and control keys) · risk: high · src: RV,RT,WH · rec: ✅ · ♻ · Gaming perf; lowers security. ReviOS applies always (see game group).
- [ ] **sec.hvci-off** — Disable Memory Integrity/HVCI (HypervisorEnforcedCodeIntegrity Enabled=0) · risk: high · src: RV,RT,WH · rec: ✅ · ♻ · Do not also set VulnerableDriverBlocklistEnable=0: ReviOS reverted it, breaks THE FINALS.
- [ ] **sec.cpu-mitigations-off** — Disable Meltdown/Spectre and Downfall mitigations (FeatureSettingsOverride/Mask) · risk: high · src: RT,OD · rec: ⛔ · ♻ · ReviOS reverted its FeatureSettings* keys; security exposure.
- [ ] **sec.uac-off** — UAC disabled (EnableLUA=0 etc.) or level changed; WH offers 5 levels · risk: high · src: RT,WH · rec: ⚠️ · ♻ · EnableLUA=0 breaks Store apps and Edge sandbox. Not in ReviOS.
- [ ] **sec.autoplay-off** — AutoPlay/AutoRun off for all drives · risk: low · src: RV,WH · rec: ✅ · 👤 ·
- [ ] **sec.show-file-extensions** — Show file extensions (HideFileExt=0) · risk: low · src: RV · rec: ✅ · 👤 · Probably duplicated in shell group; keep one.
- [ ] **sec.linked-connections** — Mapped network drives visible to elevated processes (EnableLinkedConnections=1) · risk: low · src: RV · rec: ✅ · ♻ ·
- [ ] **sec.bitlocker-auto-encrypt-off** — Prevent automatic BitLocker device encryption (PreventDeviceEncryption=1) · risk: low · src: RV,WU,WH · rec: ➕ · · ReviOS file is dead code (not wired); only helps before encryption starts.
- [ ] **sec.bitlocker-decrypt** — Disable-BitLocker on system drive (decrypt) · risk: med · src: WU · rec: ⚠️ · · Only if currently protected; decryption takes time.
- [ ] **sec.password-never-expires** — net accounts /maxpwage:unlimited · risk: low · src: RV,WU · rec: ➕ · ·
- [ ] **sec.refresh-root-certs** — Refresh trusted root certificates from Windows Update (CertUtil -generateSSTFromWU, import) · risk: low · src: RT · rec: ➕ · · One-shot action. Do not set DisableRootAutoUpdate: Store needs it.
- [ ] **sec.workplace-join-prompts-off** — Block "Allow my organization to manage my device" workplace-join prompts · risk: med · src: WH · rec: ➕ · 👤 ·
- [ ] **sec.remote-assistance-off** — Remote Assistance disabled (fAllowToGetHelp=0) · risk: low · src: WH · rec: ➕ · ·
- [ ] **sec.ps-execution-policy** — PowerShell execution policy RemoteSigned (user and machine) · risk: med · src: WH · rec: ➕ · 👤 · WH recommends RemoteSigned; Windows default Restricted.
- [ ] **sec.rdp-unsigned-warning-off** — Suppress RDP unsigned .rdp file warnings · risk: high · src: WU · rec: ⛔ · 👤 · Lowers security; phishing vector.

## Windows Update

- [ ] **upd.pause-2038** — Pause updates to 2038-01-19 via UX\Settings pause values, raise FlightSettingsMaxPauseDays · risk: med · src: RV,RT,OD,WH · rec: ✅ · 🔁 · ReviOS's chosen approach. Conflicts with upd.policy-security-only and upd.policy-disabled.
- [ ] **upd.policy-security-only** — WU policy: AUOptions=2, feature updates deferred 365d, quality 7d, BranchReadinessLevel · risk: med · src: WH · rec: ➕ · 🔁 · Alternative to upd.pause-2038 (pick one). ReviOS reverted the full policy-key approach.
- [ ] **upd.policy-disabled** — Hard-disable WU: NoAutoUpdate=1, AUOptions=1, wuauserv/UsoSvc/WaaSMedicSvc off, rename DLLs · risk: high · src: WH,WU · rec: ⛔ · 🔒 · NoAutoUpdate=1 broke Xbox sign-in; DLL renames break servicing and Store.
- [ ] **upd.drivers-wu-off** — Exclude driver updates from Windows Update (ExcludeWUDriversInQualityUpdate, DriverSearching) · risk: med · src: RV,RT,WH · rec: ✅ · · RT sets SearchOrderConfig=0 and DontPromptForWindowsUpdate too. WH exposes as toggle.
- [ ] **upd.notification-level** — WU notification level 2 (SetUpdateNotificationLevel) · risk: low · src: RV,WH · rec: ➕ · · ReviOS's revert deletes the whole WindowsUpdate policy key afterward; order matters.
- [ ] **upd.hide-upgrade-mct** — Hide upgrade-available notice and Media Creation Tool link, restart notifications off · risk: low · src: RV · rec: ✅ · ·
- [ ] **upd.delivery-optimization-off** — Delivery Optimization peer-to-peer off (DODownloadMode) · risk: low · src: RV,OD,WU,WH · rec: ✅ · · RV/OD/WU use 0 (HTTP only); WH uses 99 (bypass). Pick one.
- [ ] **upd.insider-off** — Insider/preview builds off (AllowBuildPreview=0, EnableConfigFlighting=0) and hide Insider page · risk: low · src: RV · rec: ✅ · ·
- [ ] **upd.store-autodownload-off** — Microsoft Store auto-download of app updates off, OS upgrade offer off · risk: low · src: RV,WH · rec: ➕ · · WH recommends the opposite rec=2 (keep updating).
- [ ] **upd.wmp-autoupdate-off** — Windows Media Player auto-update off · risk: low · src: RV · rec: ➕ · ·
- [ ] **upd.register-au-off** — Microsoft Update pending service RegisterWithAU=0 · risk: low · src: RV · rec: ➕ · ·
- [ ] **upd.hw-requirements-bypass** — Allow upgrades on unsupported TPM/CPU, hide unsupported-hardware notice · risk: low · src: RV,WU · rec: ➕ · · LabConfig Bypass* values are install-time only (excluded).
- [ ] **upd.hide-wu-page** — Hide Windows Update page in Settings (SettingsPageVisibility) · risk: low · src: RT · rec: ➕ · · Same SettingsPageVisibility value as misc.hide-settings-pages: combine the page list.
- [ ] **upd.restart-behavior** — Restart control: no auto-restart with logged-on users, restart notifications, expedite flags · risk: med · src: WH · rec: ➕ · ·
- [ ] **upd.wu-ux-prefs** — Other Microsoft products updates, metered-connection download, continuous-innovation opt-in toggles · risk: med · src: WH · rec: ➕ · ·
- [ ] **upd.vendor-driver-software-block** — Block driver co-installers and vendor auto-install (Razer, Logitech) · risk: med · src: WH,WU · rec: ➕ · · SearchOrderConfig=0 disables driver search globally; ACL trick can be undone.
- [ ] **upd.tasks-and-health-tools** — WU scheduled tasks, Update Health Tools, rempl removal · risk: med · src: RV · rec: ⛔ · 🔁 · Handled in task/feat groups; do not duplicate here.

## Network & DNS

- [ ] **net.dns-provider** — Set DNS servers on all adapters: Google, Cloudflare (+malware, +adult), OpenDNS, Quad9, AdGuard (+family) · risk: low · src: WU,WH · rec: ➕ · · 8 winutil providers; Automatic restores DHCP. ReviOS sets no DNS.
- [ ] **net.dns-over-https** — Register DoH templates via netsh dns add encryption for chosen provider (autoupgrade) · risk: low · src: WU,WH · rec: ➕ · · Applies to Cloudflare, Google, Quad9 (WH) and the other winutil providers; udpfallback=no.
- [ ] **net.smart-name-resolution-off** — Disable smart multi-homed name resolution (DNS no longer queried on all adapters) · risk: low · src: OD · rec: ➕ · ·
- [ ] **net.ipv4-preferred** — Prefer IPv4 over IPv6 (DisabledComponents=32) · risk: low · src: WU · rec: ➕ · ♻ · Conflicts with net.ipv6-disable.
- [ ] **net.ipv6-disable** — Disable IPv6 (DisabledComponents=255, unbind ms_tcpip6) · risk: med · src: WU · rec: ⚠️ · ♻ · Microsoft advises prefer-IPv4 instead; may break some apps.
- [ ] **net.teredo-disable** — Disable Teredo tunneling (netsh + DisabledComponents) · risk: low · src: WU,RV · rec: ➕ · ♻ · ReviOS instead resets Teredo to default; choose one.
- [ ] **net.nagle-off** — Disable Nagle (TcpAckFrequency=1, TCPNoDelay=1 on every adapter GUID) · risk: med · src: WH · rec: ⚠️ · · Latency gaming only; per-adapter.
- [ ] **net.bbr2-congestion** — BBR2 TCP congestion provider · risk: med · src: RV · rec: ⛔ · · ReviOS reverted to default: breaks websockets (issue #27).
- [ ] **net.ntp-pool** — Use pool.ntp.org instead of time.windows.com for w32tm · risk: low · src: WU · rec: ➕ · ·

## Misc

- [ ] **misc.utc-hardware-clock** — RealTimeIsUniversal=1 so hardware clock is UTC (dual-boot with Linux) · risk: med · src: RV,OD · rec: ➕ · ♻ · Windows-only systems show wrong time until resync. ReviOS applies it always.
- [ ] **misc.boot-menu-legacy** — bcdedit bootmenupolicy Legacy and lastknowngood yes · risk: low · src: RV · rec: ✅ · ♻ ·
- [ ] **misc.classic-photo-viewer** — Restore Windows Photo Viewer handler for image types · risk: low · src: RV · rec: ✅ · 🔒 · ReviOS applies only with Photos removal ([x] here); needs file-assoc remap.
- [ ] **misc.developer-mode** — Developer Mode (AllowDevelopmentWithoutDevLicense=1) · risk: low · src: OD,WH · rec: ➕ · ·
- [ ] **misc.sideload-trusted-apps** — Allow sideloading of all trusted apps (AllowAllTrustedApps=1) · risk: low · src: OD · rec: ➕ · ·
- [ ] **misc.long-paths** — Win32 long paths enabled (LongPathsEnabled=1) · risk: low · src: OD · rec: ➕ · ♻ ·
- [ ] **misc.numlock-boot** — NumLock on at boot (InitialKeyboardIndicators) · risk: low · src: OD · rec: ➕ · 👤 ·
- [ ] **misc.restore-point** — Create system restore point before applying (bypass 24h throttle) · risk: low · src: WU,OD · rec: ✅ · · Tool safety step, not a tweak; also enable System Restore protection.
- [ ] **misc.disk-cleanup** — Delete Temp, SoftwareDistribution\Download, Prefetch, thumbnail cache, CrashDumps, Windows.old · risk: med · src: OD · rec: ➕ · · One-shot action. Windows.old removal is irreversible.
- [ ] **misc.accessibility-hotkeys-off** — Disable Sticky/Filter/Toggle/Mouse Keys and High Contrast hotkeys and Narrator Win+Ctrl+Enter · risk: low · src: WH,WU · rec: ➕ · 👤 · WU Flags=506, autounattend Flags=10; WH rec values 2/2/34/130/4194.
- [ ] **misc.notification-prefs** — Toast preferences: lock-screen toasts, sounds, capability/startup-app/security toasts, bell icon, DST notice · risk: low · src: WH · rec: ➕ · 👤 · May overlap shell group; one-per-user preferences.
- [ ] **misc.startup-sound-off** — Disable Windows startup sound (DisableStartupSound) · risk: low · src: WH · rec: ➕ · ·
- [ ] **misc.audio-ducking-off** — Communication audio ducking set to Do nothing (UserDuckingPreference=3) and Narrator ducking off · risk: low · src: WH · rec: ➕ · 👤 ·
- [ ] **misc.voice-activation-off** — Voice activation for apps off (AgentActivationEnabled=0) · risk: low · src: WH · rec: ➕ · ·
- [ ] **misc.netplwiz-autologin** — Show auto-login checkbox in netplwiz (DevicePasswordLessBuildVersion=0) · risk: low · src: WH · rec: ➕ · · Storing credentials for autologon is a security tradeoff.
- [ ] **misc.regional-formats** — Short date, first day of week, decimal/list separators, measurement system (user preference) · risk: low · src: WH · rec: ➕ · 👤 · Pure preference; defaults en-US.
