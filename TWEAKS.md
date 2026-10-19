# Tweak Pick-List

Everything the reference projects offer, merged and de-duplicated into **499 selectable items**. You decide what goes into the tool: tick `[x]` the ones you want, leave the rest `[ ]`. Anything left unticked is not implemented.

- **Details for each item** (exact registry paths, values, service names, package names, per-source differences, revert hints) are in `docs/tweaks/group1..4.mech.md`, under a `### <id>` heading matching the id here.
- Raw, un-merged inventories per project are in `docs/inventory/`.
- Implementation plan: [PLAN.md](PLAN.md).

## How to use

1. Go through each section and tick what you want. Pre-ticked items `[x]` are **only** what you told me you want (your ReviOS selections). Everything else is a suggestion via `rec:`.
2. Tell me when you're done (or tell me in chat, e.g. "tick all ✅ in Privacy, skip Gaming") and I'll turn the ticked items into profiles for the engine.
3. Items marked `⛔` are listed so you can see them, but I'd not tick them.

### Legend

| Field | Meaning |
|---|---|
| `src` | RV = ReviOS playbook, RT = revision-tool, WU = winutil, WH = Winhance, OD = optimizerDuck, RS = Registry-Tweaks-Scripts. More sources usually means more agreement. |
| `rec ✅` | Recommended: low risk and widely agreed, or ReviOS always applies it |
| `rec ➕` | Optional: situational or preference |
| `rec ⚠️` | Risky: only if you know why you want it |
| `rec ⛔` | Not recommended: ReviOS reverted it because it broke something, Windows 10 only, dead code, redundant, or conflicting |
| 👤 | Per-user setting (HKCU). Needs mirroring to the default user so new accounts get it. |
| 🔒 | Needs TrustedInstaller |
| 🔁 | Windows Update tends to revert or reinstall this, so it will need re-applying |
| ♻ | Reboot needed |

### Your pre-ticked choices

Hibernate + Fast Startup off, Defender disable, remove Edge / OneDrive / Teams, remove Photos / Dev Home / Phone Link / Cross Device, remove Copilot + Recall (app, policies, optional feature), dark mode, transparency off, legacy context menu, remove pinned Start items.

**Deliberately not ticked** (you did not choose them): Xbox apps removal, Revision wallpaper, automatic maintenance off, browser install, and the broad AI-package removal (`ai.remove-ai-platform-packages`: AIX, CoreAI, WindowsWorkload and others; I judged this beyond "remove Recall and Copilot").

### Things to know before ticking

- **Conflicts:** several items are alternatives (for example `upd.pause-2038` against the update-policy items, `perf.prefetch` against `perf.superfetch-keep`). The `note` on each says which. Don't tick both sides.
- **ReviOS "always applied" is not the same as safe.** A number of its tweaks are risky for general use (IFEO priority on `lsass`/`sihost`, the Ease-of-Access wipe, short shutdown timeouts, disabling VBS). They carry `⚠️`.
- **Opaque ReviOS pieces:** the WinSxS removal packages, the Revision power plan and some `revitool` verbs can't be reproduced from source. They are listed as `⛔` or noted as skipped.
- **Unverified in a VM:** Defender disable on 24H2/25H2, `ConfigureStartPins` on Pro, and the Copilot+ package names Winhance abbreviates.

---

## Privacy & Telemetry

- [x] **priv.telemetry-policy** — Telemetry level 0 (policy + CPSS): sets AllowTelemetry=0 in every policy/CPSS/PolicyManager location · risk: low · src: RV,RT,OD,WU,WH · rec: ✅ · ♻ · Home/Pro still send Required data; 0 acts as the minimum.
- [x] **priv.datacollection-hardening** — DataCollection policy hardening: commercial pipeline, device name, feedback/opt-in UX, flighting, dump/log limits off · risk: low · src: RV,RT,OD,WH · rec: ✅ · · Companion to priv.telemetry-policy.
- [x] **priv.autologgers-off** — Telemetry ETW autologgers off: Diagtrack-Listener, SQMLogger and others set Start=0 · risk: low · src: RV,OD · rec: ✅ · 🔒 · RV disables 3 sessions; OD disables 10 (more aggressive, med risk).
- [x] **priv.appcompat-policy** — Application Compatibility telemetry off: engine, inventory, PCA, steps recorder, program telemetry · risk: med · src: RV,OD,WH · rec: ✅ · · DisableEngine=1 can stop legacy compat shims; OD/WH only set AITEnable/DisableInventory.
- [x] **priv.ceip-off** — Customer Experience Improvement Program / SQM disabled (Windows, App-V, IE, Messenger) · risk: low · src: RV · rec: ✅ · ·
- [x] **priv.content-delivery-off** — Content Delivery Manager off: silent app installs, tips, suggestions, lock-screen spotlight/fun facts · risk: low · src: RV,OD,WH,WU · rec: ✅ · 👤 · Also deletes Subscriptions and SuggestedApps keys.
- [x] **priv.cloudcontent-policies** — CloudContent/Spotlight policies: soft landing, third-party suggestions, cloud-optimized content, Spotlight, Settings ads · risk: low · src: RV,OD,WU · rec: ✅ · 👤 · Excludes DisableWindowsConsumerFeatures (see priv.consumer-features-policy).
- [ ] **priv.consumer-features-policy** — DisableWindowsConsumerFeatures=1 (stops promoted app installs) · risk: med · src: OD,WU · rec: ⛔ · · ReviOS deliberately does NOT set it: breaks Your Phone/Phone Link. Conflicts with priv.cloudcontent-policies intent.
- [x] **priv.restrict-internet-comm** — Restrict Internet communication policies: publishing wizard, web services, online prints, HTTP printing, PCHealth, registration wizard · risk: low · src: RV · rec: ✅ · 👤 · Many HKCU+HKLM values.
- [x] **priv.error-reporting-off** — Windows Error Reporting disabled (policy, consent, dumps) plus handwriting error reports · risk: low · src: RV,OD,WH · rec: ✅ · · WerSvc/PcaSvc service handling lives in svc group.
- [x] **priv.firewall-telemetry-block** — Outbound firewall rules blocking DiagTrack and WerSvc svchost to the Internet · risk: low · src: RV · rec: ✅ · 🔒 · Do NOT add the Windows-Insider (wisvc) rule: breaks Xbox. Firewall itself is otherwise left on.
- [x] **priv.hosts-telemetry-blocklist** — Replace hosts file with ~50 Microsoft telemetry/Watson/ads hosts (and Brave/VS telemetry) to 0.0.0.0 · risk: low · src: RV · rec: ✅ · · Overwrites whole hosts file; consider merging instead.
- [ ] **priv.hosts-adobe-block** — Append Ruddernation Adobe telemetry/activation URL blocklist to hosts · risk: med · src: WU · rec: ⚠️ · · External download; can break Adobe activation/licensing.
- [x] **priv.ifeo-telemetry-exes** — IFEO Debugger=taskkill for CompatTelRunner, AggregatorHost, DeviceCensus, FeatureLoader, BingChatInstaller, BGAUpsell, BCILauncher · risk: med · src: RV · rec: ➕ · 🔒🔁 · CompatTelRunner also drives upgrade-compat scans.
- [x] **priv.advertising-id-off** — Advertising ID disabled (user, machine, policy; Id deleted) · risk: low · src: RV,OD,WH,WU · rec: ✅ · 👤 ·
- [x] **priv.tailored-diagnostics-feedback** — Tailored experiences, diagnostic transcript viewer, feedback prompts (SIUF) off, DoNotShowFeedbackNotifications · risk: low · src: RV,OD,WH,WU · rec: ✅ · 👤 ·
- [x] **priv.activity-history-off** — Activity history/timeline: feed, publish and upload user activities off · risk: low · src: RV,OD,WU · rec: ✅ · · WU sets EnableActivityFeed=1 (likely source bug); use 0.
- [x] **priv.input-personalization-off** — Inking/typing/contact harvesting, TIPC, HttpAcceptLanguageOptOut off · risk: low · src: RV,RT,OD,WH,WU · rec: ✅ · 👤 · RT verb `input-personalization disable`; clears custom dictionary.
- [x] **priv.online-speech-narrator** — Online speech recognition and Narrator cloud services/scripting off · risk: low · src: RV,OD,WH,WU · rec: ➕ · 👤 · Disabling online speech removes cloud dictation.
- [x] **priv.capability-consent-deny** — App capability ConsentStore=Deny for account info, calendar, tasks, chat, radios, bluetoothSync, diagnostics, libraries, filesystem · risk: med · src: RV,WH · rec: ✅ · 👤 · Contacts/email/call history left alone (Mail&Calendar). broadFileSystemAccess Deny can break some UWP apps.
- [x] **priv.location-sensors-off** — Location and sensors off: ConsentStore, LocationAndSensors policy, Maps auto-update, lfsvc, Geolocation · risk: med · src: RV,OD,WH,WU · rec: ✅ · 👤 · Breaks maps/weather auto-location and Find My Device. lfsvc handled in svc group.
- [ ] **priv.camera-mic-access** — Camera/microphone ConsentStore Allow (or Deny) · risk: med · src: RV,WH · rec: ➕ · 👤 · ReviOS explicitly sets Allow; Deny breaks calls. Preference toggle.
- [x] **priv.find-my-device-off** — Find My Device policy disabled · risk: low · src: OD · rec: ➕ · ·
- [x] **priv.wifi-sense-off** — Wi-Fi Sense/hotspot reporting and auto-connect to suggested hotspots off · risk: low · src: RV,OD,WH · rec: ✅ · ·
- [x] **priv.settings-sync-off** — Windows Settings Sync categories disabled by policy (user override allowed) · risk: low · src: RV · rec: ✅ · · Breaks cross-device sync of themes/passwords/language.
- [x] **priv.cloud-messaging-misc** — Message cloud sync, EdgeUI help sticker, MFU tracking, NVIDIA control panel telemetry opt-out · risk: low · src: RV,OD · rec: ✅ · 👤 ·
- [x] **priv.feature-advert-tips** — Balloon feature adverts, online tips, cloud app notifications, Scoobe/finish-setup nags, suggestion toasts off · risk: low · src: RV,OD,WH,WU · rec: ✅ · 👤 ·
- [x] **priv.start-tracking-off** — Start menu tracking: Start_TrackProgs/TrackDocs, recommendations, account notifications · risk: low · src: OD,WH,WU · rec: ➕ · 👤 · May overlap start group; keep one.
- [x] **priv.search-cloud-history** — Search history, search highlights, MSA/AAD cloud search, Cortana policy off · risk: low · src: WH · rec: ➕ · 👤 · Bing-in-Start (BingSearchEnabled) belongs to start group.
- [x] **priv.mrt-reporting-off** — Malicious Software Removal Tool infection reporting off · risk: low · src: RV · rec: ✅ · ·
- [x] **priv.valuebanner-off** — Disable Settings value banner ads (ActivatableClassId ValueBanner) · risk: low · src: RV · rec: ✅ · 🔒 ·
- [x] **priv.dev-telemetry-env** — DOTNET_CLI_TELEMETRY_OPTOUT and POWERSHELL_TELEMETRY_OPTOUT machine env vars · risk: low · src: RV,WU · rec: ✅ · ·
- [x] **priv.winget-telemetry-off** — winget settings.json telemetry.disable for default user and existing profiles · risk: low · src: RV · rec: ✅ · 👤 · RV ties it to remove-pinned-items option.
- [x] **priv.office-telemetry-off** — Office ClickToRun log management/timer and all \Microsoft\Office\* scheduled tasks disabled · risk: low · src: RV · rec: ➕ · · Cross-ref task group.
- [x] **priv.rsop-logging-off** — Resultant Set of Policy logging off · risk: low · src: RV · rec: ➕ · ·
- [x] **priv.usage-reporting-off** — Usage reporting: DPS/diagsvc/WDI services, SleepStudy and power diagnostic logs off · risk: med · src: RT · rec: ➕ · 🔒 · Services overlap svc group; DPS off hides some troubleshooters.
- [x] **priv.device-metadata-network-off** — Prevent device metadata/companion apps download from network · risk: low · src: RT,WU · rec: ➕ · · Also listed under upd.drivers-wu-off in RT.
- [x] **priv.wpbt-off** — Disable Windows Platform Binary Table execution (OEM firmware-injected exes) · risk: med · src: WU · rec: ➕ · ♻ · May break OEM anti-theft/bloat tools.
- [ ] **priv.store-recommendations-block** — Deny ACL on Store store.db to stop recommended search results · risk: med · src: WU · rec: ⛔ · 🔁 · Hacky, locks Store DB; Store updates may fail.
- [ ] **priv.telemetry-removal-package** — Remove telemetry components via revitool winpackage telemetry-removal (WinSxS) · risk: high · src: RV · rec: ⛔ · · Opaque Revision signed package; not reproducible. Servicing-stack removal.
- [ ] **priv.oosu-external** — Launch O&O ShutUp10++ with a config · risk: med · src: WU · rec: ⛔ · · External software; redundant with items here.

## Security

- [x] **sec.defender-disable** — Disable Windows Defender (policy flags, core keys, MDCoreSvc off, definitions removed) · risk: high · src: RV,RT · rec: ⚠️ · 🔒♻ · Tamper Protection must be off first; Jan-2026 updates strip policy value on gpupdate. See mech.
- [ ] **sec.defender-remove-package** — Install Revision-ReviOS-Defender-Removal CBS package to remove Defender components · risk: high · src: RV,RT · rec: ⛔ · 🔒 · Needs Revision's signed CAB; not reproducible. Optional extra over sec.defender-disable.
- [x] **sec.defender-ui-hide** — Hide Defender systray, remove SecurityHealth Run entry, silence Security Center notifications · risk: low · src: RV,WH · rec: ✅ · · Pairs with sec.defender-disable.
- [ ] **sec.defender-reporting** — Defender cloud reporting: generic reports off, sample submission never, battery signature updates off · risk: low · src: RV,WU · rec: ➕ · · Redundant when Defender disabled; useful if Defender kept.
- [x] **sec.smartscreen-off** — SmartScreen off: app install control, web content evaluation, Edge phishing filter · risk: med · src: RV,RT · rec: ✅ · 👤🔁 · RT also renames smartscreen.exe to .revi and sets IFEO inside Defender flow.
- [x] **sec.smart-app-control-off** — Smart App Control Off (VerifiedAndReputablePolicyState=0) · risk: high · src: WH · rec: ➕ · ♻ · One-way: once Off, cannot be re-enabled without reinstall. Fresh installs start in evaluation.
- [x] **sec.vbs-off** — Disable Virtualization-Based Security (bcdedit vsmlaunchtype off, DeviceGuard policy and control keys) · risk: high · src: RV,RT,WH · rec: ✅ · ♻ · Gaming perf; lowers security. ReviOS applies always (see game group).
- [x] **sec.hvci-off** — Disable Memory Integrity/HVCI (HypervisorEnforcedCodeIntegrity Enabled=0) · risk: high · src: RV,RT,WH · rec: ✅ · ♻ · Do not also set VulnerableDriverBlocklistEnable=0: ReviOS reverted it, breaks THE FINALS.
- [ ] **sec.cpu-mitigations-off** — Disable Meltdown/Spectre and Downfall mitigations (FeatureSettingsOverride/Mask) · risk: high · src: RT,OD · rec: ⛔ · ♻ · ReviOS reverted its FeatureSettings* keys; security exposure.
- [ ] **sec.uac-off** — UAC disabled (EnableLUA=0 etc.) or level changed; WH offers 5 levels · risk: high · src: RT,WH · rec: ⚠️ · ♻ · EnableLUA=0 breaks Store apps and Edge sandbox. Not in ReviOS.
- [x] **sec.autoplay-off** — AutoPlay/AutoRun off for all drives · risk: low · src: RV,WH · rec: ✅ · 👤 ·
- [x] **sec.show-file-extensions** — Show file extensions (HideFileExt=0) · risk: low · src: RV · rec: ✅ · 👤 · Probably duplicated in shell group; keep one.
- [x] **sec.linked-connections** — Mapped network drives visible to elevated processes (EnableLinkedConnections=1) · risk: low · src: RV · rec: ✅ · ♻ ·
- [x] **sec.bitlocker-auto-encrypt-off** — Prevent automatic BitLocker device encryption (PreventDeviceEncryption=1) · risk: low · src: RV,WU,WH · rec: ➕ · · ReviOS file is dead code (not wired); only helps before encryption starts.
- [ ] **sec.bitlocker-decrypt** — Disable-BitLocker on system drive (decrypt) · risk: med · src: WU · rec: ⚠️ · · Only if currently protected; decryption takes time.
- [x] **sec.password-never-expires** — net accounts /maxpwage:unlimited · risk: low · src: RV,WU · rec: ➕ · ·
- [x] **sec.refresh-root-certs** — Refresh trusted root certificates from Windows Update (CertUtil -generateSSTFromWU, import) · risk: low · src: RT · rec: ➕ · · One-shot action. Do not set DisableRootAutoUpdate: Store needs it.
- [x] **sec.workplace-join-prompts-off** — Block "Allow my organization to manage my device" workplace-join prompts · risk: med · src: WH · rec: ➕ · 👤 ·
- [ ] **sec.remote-assistance-off** — Remote Assistance disabled (fAllowToGetHelp=0) · risk: low · src: WH · rec: ➕ · ·
- [x] **sec.ps-execution-policy** — PowerShell execution policy RemoteSigned (user and machine) · risk: med · src: WH · rec: ➕ · 👤 · WH recommends RemoteSigned; Windows default Restricted.
- [ ] **sec.rdp-unsigned-warning-off** — Suppress RDP unsigned .rdp file warnings · risk: high · src: WU · rec: ⛔ · 👤 · Lowers security; phishing vector.

## Windows Update

- [x] **upd.pause-2038** — Pause updates to 2038-01-19 via UX\Settings pause values, raise FlightSettingsMaxPauseDays · risk: med · src: RV,RT,OD,WH · rec: ✅ · 🔁 · ReviOS's chosen approach. Conflicts with upd.policy-security-only and upd.policy-disabled.
- [ ] **upd.policy-security-only** — WU policy: AUOptions=2, feature updates deferred 365d, quality 7d, BranchReadinessLevel · risk: med · src: WH · rec: ➕ · 🔁 · Alternative to upd.pause-2038 (pick one). ReviOS reverted the full policy-key approach.
- [ ] **upd.policy-disabled** — Hard-disable WU: NoAutoUpdate=1, AUOptions=1, wuauserv/UsoSvc/WaaSMedicSvc off, rename DLLs · risk: high · src: WH,WU · rec: ⛔ · 🔒 · NoAutoUpdate=1 broke Xbox sign-in; DLL renames break servicing and Store.
- [x] **upd.drivers-wu-off** — Exclude driver updates from Windows Update (ExcludeWUDriversInQualityUpdate, DriverSearching) · risk: med · src: RV,RT,WH · rec: ✅ · · RT sets SearchOrderConfig=0 and DontPromptForWindowsUpdate too. WH exposes as toggle.
- [x] **upd.notification-level** — WU notification level 2 (SetUpdateNotificationLevel) · risk: low · src: RV,WH · rec: ➕ · · ReviOS's revert deletes the whole WindowsUpdate policy key afterward; order matters.
- [x] **upd.hide-upgrade-mct** — Hide upgrade-available notice and Media Creation Tool link, restart notifications off · risk: low · src: RV · rec: ✅ · ·
- [x] **upd.delivery-optimization-off** — Delivery Optimization peer-to-peer off (DODownloadMode) · risk: low · src: RV,OD,WU,WH · rec: ✅ · · RV/OD/WU use 0 (HTTP only); WH uses 99 (bypass). Pick one.
- [x] **upd.insider-off** — Insider/preview builds off (AllowBuildPreview=0, EnableConfigFlighting=0) and hide Insider page · risk: low · src: RV · rec: ✅ · ·
- [x] **upd.store-autodownload-off** — Microsoft Store auto-download of app updates off, OS upgrade offer off · risk: low · src: RV,WH · rec: ➕ · · WH recommends the opposite rec=2 (keep updating).
- [x] **upd.wmp-autoupdate-off** — Windows Media Player auto-update off · risk: low · src: RV · rec: ➕ · ·
- [x] **upd.register-au-off** — Microsoft Update pending service RegisterWithAU=0 · risk: low · src: RV · rec: ➕ · ·
- [x] **upd.hw-requirements-bypass** — Allow upgrades on unsupported TPM/CPU, hide unsupported-hardware notice · risk: low · src: RV,WU · rec: ➕ · · LabConfig Bypass* values are install-time only (excluded).
- [ ] **upd.hide-wu-page** — Hide Windows Update page in Settings (SettingsPageVisibility) · risk: low · src: RT · rec: ➕ · · Same SettingsPageVisibility value as misc.hide-settings-pages: combine the page list.
- [ ] **upd.restart-behavior** — Restart control: no auto-restart with logged-on users, restart notifications, expedite flags · risk: med · src: WH · rec: ➕ · ·
- [ ] **upd.wu-ux-prefs** — Other Microsoft products updates, metered-connection download, continuous-innovation opt-in toggles · risk: med · src: WH · rec: ➕ · ·
- [ ] **upd.vendor-driver-software-block** — Block driver co-installers and vendor auto-install (Razer, Logitech) · risk: med · src: WH,WU · rec: ➕ · · SearchOrderConfig=0 disables driver search globally; ACL trick can be undone.
- [ ] **upd.tasks-and-health-tools** — WU scheduled tasks, Update Health Tools, rempl removal · risk: med · src: RV · rec: ⛔ · 🔁 · Handled in task/feat groups; do not duplicate here.

## Network & DNS

- [ ] **net.dns-provider** — Set DNS servers on all adapters: Google, Cloudflare (+malware, +adult), OpenDNS, Quad9, AdGuard (+family) · risk: low · src: WU,WH · rec: ➕ · · 8 winutil providers; Automatic restores DHCP. ReviOS sets no DNS.
- [ ] **net.dns-over-https** — Register DoH templates via netsh dns add encryption for chosen provider (autoupgrade) · risk: low · src: WU,WH · rec: ➕ · · Applies to Cloudflare, Google, Quad9 (WH) and the other winutil providers; udpfallback=no.
- [ ] **net.smart-name-resolution-off** — Disable smart multi-homed name resolution (DNS no longer queried on all adapters) · risk: low · src: OD · rec: ➕ · ·
- [x] **net.ipv4-preferred** — Prefer IPv4 over IPv6 (DisabledComponents=32) · risk: low · src: WU · rec: ➕ · ♻ · Conflicts with net.ipv6-disable.
- [ ] **net.ipv6-disable** — Disable IPv6 (DisabledComponents=255, unbind ms_tcpip6) · risk: med · src: WU · rec: ⚠️ · ♻ · Microsoft advises prefer-IPv4 instead; may break some apps.
- [ ] **net.teredo-disable** — Disable Teredo tunneling (netsh + DisabledComponents) · risk: low · src: WU,RV · rec: ➕ · ♻ · ReviOS instead resets Teredo to default; choose one.
- [ ] **net.nagle-off** — Disable Nagle (TcpAckFrequency=1, TCPNoDelay=1 on every adapter GUID) · risk: med · src: WH · rec: ⚠️ · · Latency gaming only; per-adapter.
- [ ] **net.bbr2-congestion** — BBR2 TCP congestion provider · risk: med · src: RV · rec: ⛔ · · ReviOS reverted to default: breaks websockets (issue #27).
- [ ] **net.ntp-pool** — Use pool.ntp.org instead of time.windows.com for w32tm · risk: low · src: WU · rec: ➕ · ·

## Misc

- [ ] **misc.utc-hardware-clock** — RealTimeIsUniversal=1 so hardware clock is UTC (dual-boot with Linux) · risk: med · src: RV,OD · rec: ➕ · ♻ · Windows-only systems show wrong time until resync. ReviOS applies it always.
- [x] **misc.boot-menu-legacy** — bcdedit bootmenupolicy Legacy and lastknowngood yes · risk: low · src: RV · rec: ✅ · ♻ ·
- [x] **misc.classic-photo-viewer** — Restore Windows Photo Viewer handler for image types · risk: low · src: RV · rec: ✅ · 🔒 · ReviOS applies only with Photos removal ([x] here); needs file-assoc remap.
- [ ] **misc.developer-mode** — Developer Mode (AllowDevelopmentWithoutDevLicense=1) · risk: low · src: OD,WH · rec: ➕ · ·
- [ ] **misc.sideload-trusted-apps** — Allow sideloading of all trusted apps (AllowAllTrustedApps=1) · risk: low · src: OD · rec: ➕ · ·
- [x] **misc.long-paths** — Win32 long paths enabled (LongPathsEnabled=1) · risk: low · src: OD · rec: ➕ · ♻ ·
- [ ] **misc.numlock-boot** — NumLock on at boot (InitialKeyboardIndicators) · risk: low · src: OD · rec: ➕ · 👤 ·
- [ ] **misc.restore-point** — Create system restore point before applying (bypass 24h throttle) · risk: low · src: WU,OD · rec: ✅ · · Tool safety step, not a tweak; also enable System Restore protection.
- [ ] **misc.disk-cleanup** — Delete Temp, SoftwareDistribution\Download, Prefetch, thumbnail cache, CrashDumps, Windows.old · risk: med · src: OD · rec: ➕ · · One-shot action. Windows.old removal is irreversible.
- [x] **misc.accessibility-hotkeys-off** — Disable Sticky/Filter/Toggle/Mouse Keys and High Contrast hotkeys and Narrator Win+Ctrl+Enter · risk: low · src: WH,WU · rec: ➕ · 👤 · WU Flags=506, autounattend Flags=10; WH rec values 2/2/34/130/4194.
- [ ] **misc.notification-prefs** — Toast preferences: lock-screen toasts, sounds, capability/startup-app/security toasts, bell icon, DST notice · risk: low · src: WH · rec: ➕ · 👤 · May overlap shell group; one-per-user preferences.
- [ ] **misc.startup-sound-off** — Disable Windows startup sound (DisableStartupSound) · risk: low · src: WH · rec: ➕ · ·
- [ ] **misc.audio-ducking-off** — Communication audio ducking set to Do nothing (UserDuckingPreference=3) and Narrator ducking off · risk: low · src: WH · rec: ➕ · 👤 ·
- [ ] **misc.voice-activation-off** — Voice activation for apps off (AgentActivationEnabled=0) · risk: low · src: WH · rec: ➕ · ·
- [ ] **misc.netplwiz-autologin** — Show auto-login checkbox in netplwiz (DevicePasswordLessBuildVersion=0) · risk: low · src: WH · rec: ➕ · · Storing credentials for autologon is a security tradeoff.
- [x] **misc.regional-formats** — Short date, first day of week, decimal/list separators, measurement system (user preference) · risk: low · src: WH · rec: ➕ · 👤 · Pure preference; defaults en-US.

# Group 2 pick-list: Appx / Features / AI / Edge-OneDrive-Teams

Appx ids name the package Name (family name = Name + `_<publisherId>`; resolve at runtime with Get-AppxPackage -AllUsers). RV removes all "always" apps via `revitool appx --all-users --remove`; rec ✅ = RV removes it unconditionally. Items marked ⚠️/⛔ are system-critical or have dependents.

## Appx Bloat Removal

- [x] **appx.deprovision-markers** — Deprovision keys (AppxAllUserStore\Deprovisioned) for ~55 packages so updates/new users don't reinstall them: stops reinstall after feature updates and for new profiles · risk: med · src: RV,RT · rec: ✅ · 🔒 🔁 · RV also deprovisions Paint, Notepad, Calculator, SecHealthUI, Photos for NEW users even though Start pins some; trim list if you keep them
- [x] **appx.block-outlook-devhome-autoinstall** — Blocks OOBE/Orchestrator auto-install of new Outlook and Dev Home on later updates · risk: low · src: RV · rec: ✅ · 🔁 · Needed even after removal; Windows re-queues OutlookUpdate/DevHomeUpdate workers
- [x] **appx.preinstalled-apps-block** — ContentDeliveryManager PreInstalled/OEM/SilentInstalledApps = 0 so Windows stops silently pushing apps · risk: low · src: RV,OD,WH · rec: ✅ · 👤 · Overlaps priv content-delivery item; dedupe in catalog
- [ ] **appx.vclibs-restore** — Re-install Desktop/UWPDesktop VCLibs from Store after mass removals · risk: low · src: RV,RT · rec: ➕ · Safety net; RV runs always because removals can drop VCLibs. Prefer never removing frameworks instead
- [ ] **appx.frameworks-do-not-remove** — Microsoft.VCLibs.*, Microsoft.UI.Xaml.*, Microsoft.NET.Native.*, WindowsAppRuntime.*, Microsoft.Advertising.Xaml: shared frameworks other apps depend on · risk: high · src: RV,OD · rec: ⛔ · ⛔ Guard only: tool should skip IsFramework packages; RV list includes `Microsoft.Advertising` (check it only matches Advertising.Xaml/ads app)
- [ ] **appx.store** — Microsoft Store (Microsoft.WindowsStore) · risk: high · src: WH,OD · rec: ⛔ · ⛔ Winget/Store installs, Xbox, many apps depend on it; also needs DisableRootAutoUpdate left untouched (RV gotcha)
- [ ] **appx.store-purchase-app** — Store Purchase App (Microsoft.StorePurchaseApp) · risk: high · src: OD · rec: ⛔ · ⛔ Needed for Store purchases/licensing
- [ ] **appx.app-installer** — App Installer / winget (Microsoft.DesktopAppInstaller) · risk: high · src: WH,OD · rec: ⛔ · ⛔ Provides winget and MSIX install; RV also writes winget settings into its LocalState
- [ ] **appx.windows-security-ui** — Windows Security app (Microsoft.SecHealthUI) · risk: high · src: RV,OD · rec: ⛔ · ⛔ RV only deprovisions it; do not remove even when Defender is disabled (Settings/Windows Security UI)
- [ ] **appx.terminal** — Windows Terminal (Microsoft.WindowsTerminal, +Preview) · risk: med · src: WH,OD · rec: ⚠️ · ⚠️ Default console host on 24H2; removal leaves conhost; keep
- [ ] **appx.calculator** — Calculator (Microsoft.WindowsCalculator) · risk: med · src: WU,WH,OD · rec: ⚠️ · ⚠️ Usually wanted; RV keeps it pinned (only deprovisions)
- [ ] **appx.notepad** — Notepad (Microsoft.WindowsNotepad) · risk: med · src: WU,WH,OD · rec: ⚠️ · ⚠️ Usually wanted; RV keeps it. See feat.notepad-legacy-capability for the Win32 fallback
- [ ] **appx.snipping-tool** — Snipping Tool (Microsoft.ScreenSketch) · risk: med · src: WU,WH,OD · rec: ⚠️ · ⚠️ Usually wanted; handles Win+Shift+S capture UI
- [ ] **appx.paint** — Paint (Microsoft.Paint) · risk: low · src: WU,WH,OD,RV · rec: ➕ · RV only deprovisions it; removing leaves no mspaint unless legacy capability present
- [x] **appx.paint3d** — Paint 3D (Microsoft.MSPaint) · risk: low · src: RV,WH,OD · rec: ✅ · Different from Microsoft.Paint (the modern Paint); unpublished in Store
- [x] **appx.photos** — Photos (Microsoft.Windows.Photos) · risk: med · src: RV,WU,WH,OD · rec: ✅ · ⚠️ Pair with classic Photo Viewer + file-association re-mapping (see misc); Photos is a dependency of some image associations/Widgets previews
- [x] **appx.devhome** — Dev Home / Windows Advanced Settings (Microsoft.Windows.DevHome) · risk: low · src: RV,WU,WH,OD · rec: ✅ · 🔁 · Pair with appx.block-outlook-devhome-autoinstall
- [x] **appx.yourphone** — Phone Link (Microsoft.YourPhone) · risk: low · src: RV,WU,WH,OD · rec: ✅ · Also hides Settings page `crossdevice`; RV gotcha: DisableWindowsConsumerFeatures breaks it (not applicable once removed)
- [x] **appx.crossdevice** — Cross Device / Mobile Devices (MicrosoftWindows.CrossDevice) · risk: med · src: RV,WU,WH,OD · rec: ✅ · Loses phone mirroring, file transfer, hotspot handoff; also blocks Cross Device Resume (see shell)
- [x] **appx.camera** — Camera (Microsoft.WindowsCamera) · risk: low · src: RV,WU,WH,OD · rec: ✅ · Webcam access for other apps unaffected
- [x] **appx.widgets-webexperience** — Widgets board (MicrosoftWindows.Client.WebExperience) · risk: med · src: RV,OD · rec: ✅ · 🔁 · ⚠️ Since 22621.1343 Windows reinstalls it unless Dsh\AllowNewsAndInterests=0 (see start); Winhance/winutil call it "Start Experiences"
- [x] **appx.widgets-platform-runtime** — Widgets Platform Runtime (Microsoft.WidgetsPlatformRuntime) · risk: low · src: RV,OD · rec: ✅ · Remove together with WebExperience
- [x] **appx.start-experiences** — Start Experiences App (Microsoft.StartExperiencesApp) · risk: low · src: RV,WU,OD · rec: ✅ · Widgets/feeds host used by Start; RV always removes
- [x] **appx.secure-assessment-browser** — Secure Assessment Browser (Microsoft.Windows.SecureAssessmentBrowser) · risk: low · src: RV · rec: ✅ · ⚠️ Education exam lockdown browser; system-provisioned, safe for personal PCs
- [ ] **appx.people-experience-host** — People Experience Host (Microsoft.Windows.PeopleExperienceHost) · risk: med · src: RV · rec: ⚠️ · ⚠️ Shell-integrated system app (taskbar people/contact flyouts); RV removes but not a normal user app
- [x] **appx.alarms-clock** — Clock / Alarms (Microsoft.WindowsAlarms) · risk: low · src: RV,WU,WH,OD · rec: ✅ · Also provides Focus Sessions
- [x] **appx.maps** — Maps (Microsoft.WindowsMaps) · risk: low · src: RV,WU,WH,OD · rec: ✅ · Unpublished in Store (cannot reinstall)
- [x] **appx.sticky-notes** — Sticky Notes (Microsoft.MicrosoftStickyNotes) · risk: low · src: RV,WU,WH,OD · rec: ✅ · Notes sync via MS account is lost
- [x] **appx.mail-calendar** — Mail and Calendar (microsoft.windowscommunicationsapps) · risk: low · src: RV,WH,OD · rec: ✅ · RV gotcha: Contacts consent left allowed for it; new Outlook may auto-install when legacy Mail is removed
- [x] **appx.outlook-new** — Outlook for Windows (Microsoft.OutlookForWindows, OutlookPWA) · risk: low · src: RV,WU,WH,OD · rec: ✅ · 🔁 · Pair with appx.block-outlook-devhome-autoinstall
- [x] **appx.people** — People (Microsoft.People) · risk: low · src: RV,WH,OD · rec: ✅ · Not reinstallable from Store
- [x] **appx.bing-news** — Microsoft News (Microsoft.BingNews, alias Microsoft.News) · risk: low · src: RV,WU,WH,OD · rec: ✅
- [x] **appx.bing-weather** — MSN Weather (Microsoft.BingWeather) · risk: low · src: RV,WU,WH,OD · rec: ✅ · Weather widget on taskbar disappears
- [x] **appx.bing-search** — Bing Search (Microsoft.BingSearch) · risk: low · src: RV,WU,WH,OD · rec: ✅ · Web results in Start/Search; pair with search policies (see start)
- [x] **appx.bing-extras** — Bing Finance/Sports/FoodAndDrink/HealthAndFitness/Travel/Translator + MicrosoftStart · risk: low · src: OD · rec: ➕ · Mostly absent on 24H2; harmless to include
- [x] **appx.solitaire** — Solitaire Collection (Microsoft.MicrosoftSolitaireCollection) · risk: low · src: RV,WU,WH,OD · rec: ✅
- [x] **appx.feedback-hub** — Feedback Hub (Microsoft.WindowsFeedbackHub) · risk: low · src: RV,WU,WH,OD · rec: ✅ · RV also hides privacy-feedback Settings page
- [x] **appx.get-help** — Get Help (Microsoft.GetHelp) · risk: low · src: RV,WU,WH,OD · rec: ✅ · Settings "Get help" links stop working
- [x] **appx.tips** — Tips / Get Started (Microsoft.Getstarted) · risk: low · src: RV,WH,OD · rec: ✅ · Not reinstallable from Store
- [x] **appx.todo** — Microsoft To Do (Microsoft.Todos) · risk: low · src: RV,WU,WH,OD · rec: ✅
- [x] **appx.power-automate** — Power Automate (Microsoft.PowerAutomateDesktop) · risk: low · src: RV,WU,WH,OD · rec: ✅
- [x] **appx.cortana** — Cortana (Microsoft.549981C3F5F10) · risk: low · src: RV,WH,OD · rec: ✅ · Dead app; not reinstallable
- [x] **appx.quick-assist** — Quick Assist Store app (MicrosoftCorporationII.QuickAssist) · risk: low · src: RV,WU,WH,OD · rec: ✅ · Loses remote-help; see feat.quick-assist-legacy-capability for the capability version
- [x] **appx.family-safety** — Microsoft Family (MicrosoftCorporationII.MicrosoftFamily) · risk: low · src: RV,WH,OD · rec: ✅
- [ ] **appx.support-diagnostic-tool** — Microsoft Support Diagnostic Tool (MicrosoftCorporationII.MicrosoftSupportDiagnosticTool) · risk: low · src: OD · rec: ➕ · OD lists as caution; ReviOS leaves it
- [x] **appx.media-player** — Media Player (Microsoft.ZuneMusic) · risk: low · src: RV,WU,WH,OD · rec: ✅ · Removes the default audio/video player and associations; install VLC/mpv first
- [x] **appx.movies-tv** — Movies & TV (Microsoft.ZuneVideo) · risk: low · src: RV,WU,WH,OD · rec: ✅
- [x] **appx.sound-recorder** — Sound Recorder (Microsoft.WindowsSoundRecorder) · risk: low · src: RV,WU,WH,OD · rec: ✅
- [x] **appx.clipchamp** — Clipchamp (Clipchamp.Clipchamp) · risk: low · src: RV,WU,WH,OD · rec: ✅
- [x] **appx.whiteboard** — Whiteboard (Microsoft.Whiteboard) · risk: low · src: RV,OD · rec: ✅
- [x] **appx.surfacehub-apps** — Teams and Mail for Surface Hub (Microsoft.MicrosoftTeamsforSurfaceHub, MicrosoftCorporationII.MailforSurfaceHub) · risk: low · src: RV · rec: ✅ · Not present on most consumer images
- [x] **appx.powerbi** — Power BI (Microsoft.MicrosoftPowerBIForWindows) · risk: low · src: RV,OD · rec: ✅
- [x] **appx.skype** — Skype (Microsoft.SkypeApp) · risk: low · src: RV,WH,OD · rec: ✅ · Retired
- [x] **appx.office-hub** — Microsoft 365 / Office hub (Microsoft.MicrosoftOfficeHub) · risk: low · src: RV,WU,WH,OD · rec: ✅ · Hub/Copilot launcher; see ai.copilot-mic-and-genai-privacy for its mic consent
- [x] **appx.office-desktop-stubs** — Office Word/Excel/PowerPoint store stubs (Microsoft.Office.Word/Excel/PowerPoint) · risk: low · src: RV · rec: ✅ · Only the Store stubs; desktop Office installs unaffected
- [x] **appx.onenote** — OneNote for Windows (Microsoft.Office.OneNote) · risk: low · src: RV,WH,OD,WU · rec: ✅ · Winhance additionally uninstalls the desktop OneNote via its Uninstall string; skip that if you use it
- [x] **appx.m365-companions** — Microsoft 365 Companions (Microsoft.M365Companions) · risk: low · src: OD · rec: ➕ · Taskbar/Start people-files-calendar companions
- [x] **appx.spotify** — Spotify (SpotifyAB.SpotifyMusic) · risk: low · src: RV,OD · rec: ✅ · Store stub only
- [x] **appx.3d-viewer** — 3D Viewer (Microsoft.Microsoft3DViewer) · risk: low · src: RV,WH,OD · rec: ✅
- [x] **appx.mixed-reality-portal** — Mixed Reality Portal (Microsoft.MixedReality.Portal) · risk: low · src: RV,WH,OD · rec: ✅ · Deprecated in 24H2
- [x] **appx.third-party-promos** — OEM/sponsored third-party stubs (Disney, Amazon, Netflix, TikTok, Candy Crush, Instagram, Facebook, LinkedIn, Hulu, WinZip, Adobe Express, etc.) · risk: low · src: OD · rec: ➕ · Full name list in mech; many are Win10-era
- [x] **appx.legacy-win10-leftovers** — Messaging, OneConnect, Wallet, Print3D, 3DBuilder, Office.Sway, MicrosoftJournal, NetworkSpeedTest, MinecraftUWP · risk: low · src: OD,WU · rec: ➕ · Rarely present on 24H2
- [x] **appx.windows-aihub** — Windows.AIHub appx · risk: low · src: OD · rec: ➕ · See ai.remove-ai-platform-packages
- [ ] **appx.xbox-identity-provider** — Xbox Identity Provider (Microsoft.XboxIdentityProvider) · risk: med · src: WU,WH,OD · rec: ⚠️ · ⚠️ Breaks MS-account sign-in in non-Xbox games/apps; XboxGipSvc also affected
- [ ] **appx.xbox-tcui** — Xbox Live in-game UI (Microsoft.Xbox.TCUI) · risk: med · src: WU,WH,OD · rec: ⚠️ · ⚠️ Same sign-in breakage as Identity Provider
- [x] **appx.xbox-app** — Xbox app (Microsoft.GamingApp, Microsoft.XboxApp) · risk: low · src: WU,WH,OD · rec: ➕ · User did NOT choose Xbox removal. Game Pass/launcher gone
- [ ] **appx.xbox-game-bar** — Xbox Game Bar (Microsoft.XboxGamingOverlay, XboxGameOverlay) · risk: med · src: WU,WH,OD · rec: ➕ · Needs ms-gamebar protocol fix or Win+G shows "get an app" popup; user did NOT choose
- [x] **appx.xbox-speech-overlay** — Xbox Speech To Text Overlay (Microsoft.XboxSpeechToTextOverlay) · risk: low · src: WU,OD · rec: ➕
- [ ] **appx.xbox-gaming-services** — Gaming Services / GameCallableUI (Microsoft.GamingServices, Microsoft.XboxGameCallableUI) · risk: high · src: RT,OD · rec: ⚠️ · ⚠️ Game Pass/Store game dependency; only removed by RT's xbox-removal
- [ ] **appx.xbox-winsxs-removal** — RT `winpackage xbox-removal` (strips Xbox stack at WinSxS level) + ms-gamebar URL protocol fix · risk: med · src: RV,RT · rec: ➕ · Not chosen by user; RV default OFF. Conflicts with the individual Xbox appx items
- [ ] **appx.copilot-plus-names** — Winhance's abbreviated Copilot+ names: MicrosoftWindows.Voiess, .Speion, .Livtop, .InpApp, .Filons · risk: med · src: WH · rec: ⚠️ · ⚠️ Suspicious/possibly truncated; verify each with Get-AppxPackage -AllUsers before use. Not Store-reinstallable
- [ ] **appx.codec-extensions** — HEIF/WebP/WebMedia/VP9/AV1/HEVC/MPEG2/RawImage Image/Video Extensions · risk: med · src: OD · rec: ⛔ · ⛔ Codec providers for Photos/Explorer thumbnails; OD marks Caution; do not remove
- [ ] **appx.remote-desktop-app** — Microsoft Remote Desktop store app (Microsoft.RemoteDesktop) · risk: med · src: OD · rec: ⚠️ · ⚠️ Often absent; separate from built-in mstsc
- [ ] **appx.oem-bloat** — OEM apps (AD2F1837.* HP, DellInc.*, Lenovo*, LGMonitorApp, etc.) · risk: med · src: OD · rec: ⚠️ · ⚠️ May include driver/control-panel hosts; review each by name

## Windows Features & Capabilities

- [ ] **feat.winsxs-system-components-removal** — RT `winpackage system-components-removal` CBS package (Revi's opaque list) · risk: high · src: RV,RT · rec: ⚠️ · 🔒 ♻ · RV applies always but it caused issue #49 breakages; package contents not in repo
- [x] **feat.update-health-tools-removal** — Uninstall Update Health Tools, PC Health Check, Windows Installation Assistant · risk: low · src: RV · rec: ✅ · 🔁 · Windows Update tends to reinstall Update Health Tools (KB platform updates)
- [ ] **feat.powershell-v2** — Disable MicrosoftWindowsPowerShellV2 + Root optional features · risk: low · src: RV · rec: ➕ · ♻ · RV script exists but is dead code (not wired); common hardening
- [ ] **feat.workfolders-client** — Disable WorkFolders-Client · risk: low · src: RV · rec: ➕ · ♻ · Dead code in RV
- [ ] **feat.msrdc-infrastructure** — Disable MSRDC-Infrastructure (Remote Desktop Connection infra) · risk: med · src: RV · rec: ➕ · ♻ · Dead code in RV; check you don't need RDP app-remoting
- [ ] **feat.printing-foundation** — Disable Printing-Foundation-Features and InternetPrinting-Client · risk: med · src: RV · rec: ⚠️ · ♻ · Removes IPP/internet printing and some network printer discovery; dead code in RV
- [ ] **feat.directplay-legacy-components** — Enable DirectPlay and LegacyComponents for old games · risk: low · src: RV,WU · rec: ➕ · ♻ · Enable, not remove; RV script dead code, winutil offers it as "Legacy media"
- [x] **feat.internet-explorer-capability** — Remove Browser.InternetExplorer capability · risk: low · src: WH · rec: ➕ · Usually already absent on 24H2
- [x] **feat.powershell-ise-capability** — Remove PowerShell ISE capability · risk: low · src: WH · rec: ➕
- [x] **feat.quick-assist-legacy-capability** — Remove App.Support.QuickAssist (legacy Quick Assist) · risk: low · src: WH · rec: ➕ · Store QuickAssist is a separate item (appx.quick-assist)
- [x] **feat.steps-recorder-capability** — Remove App.StepsRecorder capability · risk: low · src: WH · rec: ➕
- [ ] **feat.wmp-legacy-capability** — Remove Media.WindowsMediaPlayer capability · risk: low · src: WH · rec: ➕ · Conflicts with feat.directplay-legacy-components if you want winutil's "legacy media" set
- [x] **feat.wordpad-capability** — Remove Microsoft.Windows.WordPad capability · risk: low · src: WH · rec: ➕ · Already removed by default in 24H2
- [x] **feat.notepad-legacy-capability** — Remove Microsoft.Windows.Notepad capability (old Win32 Notepad) · risk: low · src: WH · rec: ➕ · Separate from Store Notepad; if you also remove the appx you have no Notepad
- [ ] **feat.paint-legacy-capability** — Remove Microsoft.Windows.MSPaint capability (Win32 Paint) · risk: med · src: WH · rec: ⚠️ · ⚠️ If combined with appx.paint removal, no mspaint remains
- [ ] **feat.openssh-client-capability** — Remove OpenSSH.Client capability · risk: med · src: WH · rec: ⚠️ · ⚠️ ssh/scp used by git and dev tools
- [ ] **feat.openssh-server-capability** — Remove OpenSSH.Server capability · risk: low · src: WH · rec: ➕ · Normally not installed
- [ ] **feat.wsl-disable** — Disable Microsoft-Windows-Subsystem-Linux (and VirtualMachinePlatform) · risk: low · src: WH · rec: ➕ · ♻ · Do not select if you use WSL
- [ ] **feat.hyper-v-disable** — Disable Hyper-V, Hypervisor Platform, Hyper-V tools · risk: med · src: WH · rec: ➕ · ♻ · Breaks WSL2/Sandbox/Android emulators/VBS-related features; rarely desired together with perf VBS-off
- [ ] **feat.windows-sandbox-disable** — Disable Containers-DisposableClientVM · risk: low · src: WH · rec: ➕ · ♻
- [ ] **feat.netfx3-disable** — Disable .NET Framework 3.5 (NetFx3) · risk: low · src: WH · rec: ➕ · ♻ · Some legacy apps/installers need it
- [ ] **feat.reserved-storage-off** — DISM Set-ReservedStorageState Disabled + ShippedWithReserves=0 · risk: med · src: WU · rec: ➕ · Re-enable before feature updates or they may fail
- [ ] **feat.component-cleanup-resetbase** — DISM StartComponentCleanup /ResetBase (+ cleanmgr) · risk: med · src: WU · rec: ⚠️ · ⚠️ ResetBase is irreversible (no uninstalling updates)
- [ ] **feat.legacy-f8-boot-menu** — bcdedit bootmenupolicy legacy · risk: low · src: WU · rec: ➕ · Enables F8 Safe Mode menu
- [x] **misc.hide-settings-pages** — Hide Settings pages: cortana, privacy-feedback, windowsinsider, home (+ crossdevice, aicomponents) · risk: low · src: RV,RT,OD · rec: ✅ · RV places this in its Features section; related Insider-page/WU tray hide in next item
- [x] **misc.hide-insider-page-wu-tray** — HideInsiderPage=1 and Windows Update tray icon hidden · risk: low · src: RV · rec: ➕
- [x] **misc.enable-sudo** — Enable sudo for Windows (Sudo\Enabled=3, inline) · risk: low · src: RV · rec: ➕ · 24H2+ feature
- [ ] **misc.accessibility-reset** — Wipe Ease-of-Access hotkey/flag hives and set Flags=0 (Sticky/Filter/Toggle keys prompts off) · risk: med · src: RV · rec: ➕ · 👤 · Accessibility users should skip
- [x] **misc.typing-suggestions-off** — Autocorrect/spellcheck/text prediction/Input Insights off (TabletTip, Input\Settings) · risk: low · src: RV · rec: ✅ · 👤 · Also covers Winhance "Input Insights"
- [ ] **misc.clipboard-history-off** — Clipboard history off but policy keeps it allowed · risk: low · src: RV · rec: ➕ · 👤
- [ ] **misc.offline-maps** — Offline maps wifi-only, no auto-update · risk: low · src: RV · rec: ➕
- [x] **misc.inking-workspace** — Ink Workspace suggested apps off · risk: low · src: RV · rec: ➕

## AI (Copilot/Recall)

- [x] **ai.remove-copilot-appx** — Remove Copilot app (Microsoft.Copilot, Windows.Ai.Copilot.Provider, MicrosoftWindows.Client.CoPilot) · risk: low · src: RV,RT,WU,WH,OD · rec: ✅ · 🔁 · Store ID 9nht9rb2f4hd to reinstall; pair with ai.disable-copilot-policy
- [x] **ai.disable-copilot-policy** — TurnOffWindowsCopilot=1 (HKLM+HKCU), hide button, block shell extension · risk: low · src: OD,WH · rec: ✅ · 👤 · Redundant after removal but blocks resurrection; Win11 24H2+ legacy policy
- [x] **ai.disable-recall-policy** — Recall policies: DisableAIDataAnalysis, AllowRecallEnablement=0, TurnOffSavingSnapshots · risk: low · src: RV,OD,WH · rec: ✅ · 👤 · RV sets only DisableAIDataAnalysis=1; 26100.3915+ may remove the bits
- [x] **ai.recall-feature-remove** — Disable-WindowsOptionalFeature Recall (-Remove) · risk: low · src: OD,WU · rec: ✅ · ♻ · The hard way to kill Recall
- [ ] **ai.remove-ai-platform-packages** — Remove AIX, CoreAI, AIFabric.CBS, WindowsWorkload.*, ActionsServer, aimgr, WritingAssistant, Windows.AIHub · risk: med · src: RT,WU,WH,OD · rec: ⚠️ · 🔒 · Needs FeatureManagement Overrides so Explorer doesn't fall back to ribbon; disable WSAIFabricSvc
- [ ] **ai.winsxs-ai-removal** — RT `winpackage ai-removal` CBS package (Revision-ReviOS-AI-Removal) · risk: high · src: RV,RT · rec: ⚠️ · 🔒 ♻ · RV default ON (remove-winsxs-ai); contents not in repo; alternative is the explicit items above
- [x] **ai.disable-click-to-do** — DisableClickToDo=1 (HKLM+HKCU) · risk: low · src: OD,WH · rec: ✅ · 👤 · 24H2+
- [ ] **ai.windows-ai-agent-policies** — Disable Settings Agent, Agent Connectors/Workspaces/Remote Connectors, Copilot Runtime · risk: low · src: WH · rec: ➕ · 25H2-era WindowsAI policies
- [ ] **ai.copilot-shell-surfaces** — Hide Copilot/Recall/companion/PWA taskbar pins, IsCopilotAvailable, Bing Chat eligibility, nudges · risk: low · src: OD,WH · rec: ➕ · 👤
- [ ] **ai.copilot-hardware-key** — Neutralize Copilot keyboard key (SetCopilotHardwareKey="") · risk: low · src: WH · rec: ➕
- [ ] **ai.copilot-mic-and-genai-privacy** — Deny generativeAI/systemAIModels capability access and Copilot/Office Hub mic consent · risk: low · src: WH · rec: ➕ · 👤 · Consent value + LetAppsAccess* policies
- [ ] **ai.consumer-ai-content** — DisableConsumerAccountStateContent=1 · risk: low · src: WH · rec: ➕ · Not DisableWindowsConsumerFeatures (that breaks Phone Link per RV)
- [ ] **ai.hide-ai-settings-pages** — Hide aicomponents and privacy-systemaimodels Settings pages · risk: low · src: OD,WU · rec: ➕
- [ ] **ai.notepad-ai-disable** — HKLM\SOFTWARE\Policies\WindowsNotepad\DisableAIFeatures=1 · risk: low · src: WU · rec: ➕
- [ ] **ai.paint-ai-disable** — Paint DisableImageCreator/Cocreator/GenerativeFill/GenerativeErase/RemoveBackground=1 · risk: low · src: WH · rec: ➕
- [x] **ai.bing-copilot-ifeo-block** — IFEO taskkill for BingChatInstaller, BGAUpsell, BCILauncher · risk: low · src: RV · rec: ✅ · 🔒 · Shared with priv IFEO item; dedupe
- [ ] **ai.edge-ai-policies** — Edge Copilot sidebar/page context/compose/AI history/theme/DevTools AI policies · risk: low · src: WH · rec: ➕ · Moot when Edge is removed
- [ ] **ai.office-copilot-policies** — Office connected experiences, AI training, Word/Excel/OneNote Copilot off · risk: low · src: WH · rec: ➕ · 👤 · Only matters with desktop Office
- [ ] **ai.vivetool-recall-flag** — ViVeTool /disable /id:47205210 · risk: med · src: WU · rec: ⛔ · Needs external binary and undocumented ID; redundant with Recall removal

## Edge/OneDrive/Teams

- [x] **edge.remove-edge** — Remove Microsoft Edge Chromium (+legacy), uninstall via EDGE.ps1 technique, keep WebView2 · risk: high · src: RV,WU,WH · rec: ✅ · 🔁 · RV default ON; needs non-EU region for BrowserReplacement trick. Edge reinstalled by updates; pair with edge.block-edge-reinstall
- [x] **edge.block-edge-reinstall** — EdgeUpdate policies: InstallDefault=0, Install{Edge}=0, Install{WebView2}=1, DoNotUpdateToEdgeWithChromium=1 + Edge appx deprovision · risk: low · src: RV · rec: ✅ · 🔒 🔁 · Pairs with edge.remove-edge; WebView2 stays allowed
- [x] **edge.keep-webview2** — Guard: never remove msedgewebview2/EdgeWebView or EdgeUpdate ClientState · risk: low · src: RV,WH · rec: ✅ · Many apps need WebView2; backup ClientState before EdgeUpdate uninstall
- [x] **edge.edgeupdate-manual** — edgeupdate, edgeupdatem, MicrosoftEdgeElevationService startup = Manual (not Disabled) · risk: low · src: RV,OD · rec: ✅ · RV gotcha: Disabled breaks WebView2 install from Visual Studio
- [ ] **edge.remove-webview2** — Uninstall WebView2 runtime / EdgeUpdate (EDGE.ps1 other modes) · risk: high · src: RV,RS · rec: ⛔ · ⛔ Unused by RV; breaks Widgets, Teams, Office, Store apps
- [ ] **edge.protocol-redirect** — Redirect microsoft-edge: and MSEdgeHTM handlers to default browser (OpenWebSearch stub + IFEO) · risk: med · src: WH · rec: ➕ · 🔒 · Use after Edge removal so Start/Widgets links don't error  **DEFERRED: needs the ie_to_edge_stub.exe helper binary from Winhance, not available here; without it microsoft-edge: links stay broken after Edge removal.**
- [ ] **edge.reremoval-task** — Scheduled task re-running Edge removal at startup and deleting *Edge* tasks · risk: med · src: WH · rec: ➕ · 🔁 · Only if updates keep bringing Edge back
- [ ] **edge.policies-debloat** — Edge policies: no shopping/rewards/collections/wallet/recommendations, no first-run, startup boost/background off · risk: low · src: WU · rec: ➕ · Moot if Edge removed; ExtensionInstallBlocklist entry included
- [x] **edge.no-desktop-shortcut** — CreateDesktopShortcutDefault=0 and delete Public Edge shortcut · risk: low · src: WU · rec: ➕
- [ ] **edge.data-optin-off** — DataCollection\MicrosoftEdgeDataOptIn=0 · risk: low · src: OD · rec: ➕
- [x] **edge.remove-onedrive** — Uninstall OneDrive, clean AppData/Start/tasks/Run keys, hide nav pane, stop new profiles getting it · risk: med · src: RV,RT,WU,WH · rec: ✅ · 🔁 · RV default ON; user data in %USERPROFILE%\OneDrive is not deleted by Winhance
- [ ] **edge.onedrive-block-backup-prompts** — KFMBlockOptIn=1 (HKLM+HKCU) stops known-folder backup nags · risk: low · src: WH · rec: ➕ · 👤 · Only needed if OneDrive is kept
- [ ] **edge.onedrive-disable-sync-policy** — DisableFileSyncNGSC policy · risk: med · src: RV,WU · rec: ⛔ · ⛔ RV deliberately deletes this key ("workaround"); winutil sets it to 0 (no effect)
- [x] **edge.remove-teams** — Remove Teams (MSTeams, MicrosoftTeams, Flipgrid) and Teams Meeting Add-in MSI · risk: low · src: RV,WU,WH,OD · rec: ✅ · Kill teams processes first to avoid long removal
- [x] **edge.block-teams-autoinstall** — ConfigureChatAutoInstall=0 · risk: low · src: RV · rec: ✅ · 🔁 · RV applies always, independent of Teams removal

## Services

- [x] **svc.reviOS-service-set** — ReviOS service set: dam, GpuEnergyDrv, NetBT, Telemetry, diagnosticshub.standardcollector, WerSvc, DiagTrack, wisvc, PcaSvc, WdiServiceHost/SystemHost, tcpipreg, Wecsvc, UCPD disabled; edgeupdate=Manual; condrv=Automatic · risk: med · src: RV · rec: ✅ · 🔒 · bundle of the svc.* lines below marked "in RV set"; pick bundle OR individual lines. Excludes reverted bam/Ndu/DPS/GraphicsPerfSvc/Beep
- [x] **svc.diagtrack** — Connected User Experiences & Telemetry (DiagTrack): set Disabled · risk: low · src: RV,WU,WH,OD · rec: ✅ · 🔒 · in RV set. WH only sets Manual; OD's bulk table re-sets it conflicting in order
- [ ] **svc.dmwappushservice-dcpsvc** — WAP push message routing and DcpSvc telemetry data-collection service: set Disabled · risk: low · src: OD · rec: ➕ · 🔒 · OD's bulk table resets these to Manual; apply after it
- [x] **svc.diagnosticshub** — Diagnostics Hub standard collector service: set Disabled · risk: low · src: RV,OD · rec: ✅ · 🔒 · in RV set
- [x] **svc.wersvc** — Windows Error Reporting service (WerSvc; WU also wermgr): set Disabled · risk: low · src: RV,WU,WH,OD,RS · rec: ✅ · 🔒 · in RV set. Pair with task.wer-queue; WH default is Manual
- [x] **svc.pcasvc** — Program Compatibility Assistant service: set Disabled · risk: low · src: RV,WH,OD · rec: ✅ · 🔒 · in RV set. No more compat prompts
- [x] **svc.wisvc** — Windows Insider service: set Disabled · risk: low · src: RV,WH,RS · rec: ✅ · 🔒 · in RV set
- [x] **svc.wdi-hosts** — Diagnostic Service Host and Diagnostic System Host (WdiServiceHost, WdiSystemHost): set Disabled · risk: low · src: RV · rec: ✅ · 🔒 · in RV set. Disables troubleshooter diagnostics
- [x] **svc.dam** — Desktop Activity Moderator driver (dam): set Disabled · risk: med · src: RV · rec: ✅ · 🔒 ♻ · in RV set
- [x] **svc.gpuenergydrv** — GPU energy telemetry driver (GpuEnergyDrv): set Disabled · risk: low · src: RV · rec: ✅ · 🔒 ♻ · in RV set
- [x] **svc.netbt** — NetBIOS over TCP/IP driver (NetBT): set Disabled · risk: med · src: RV · rec: ✅ · 🔒 ♻ · in RV set. Breaks legacy SMB/NetBIOS name resolution
- [x] **svc.intel-telemetry** — Intel telemetry service ("Telemetry"): set Disabled · risk: low · src: RV · rec: ✅ · 🔒 · in RV set
- [x] **svc.tcpipreg-wecsvc** — tcpipreg (experimental) and Windows Event Collector (Wecsvc): set Disabled · risk: low · src: RV · rec: ✅ · 🔒 · in RV set
- [x] **svc.ucpd** — User Choice Protection Driver (UCPD) disabled so default-app hashes can be changed · risk: med · src: RV · rec: ✅ · 🔒 ♻ 🔁 · in RV set. Pair with task.ucpd-velocity
- [x] **svc.edgeupdate-manual** — Edge Update service: set Manual, not Disabled · risk: low · src: RV · rec: ✅ · 🔒 · in RV set. Disabling breaks WebView2 installs via Visual Studio
- [x] **svc.condrv-auto** — Console driver (condrv) set Automatic · risk: low · src: RV · rec: ✅ · 🔒 · in RV set. Fixes error 0xd000003a
- [ ] **svc.sysmain-off** — SysMain/Superfetch (+ReadyBoost rdyboost, EnablePrefetcher) set Disabled · risk: med · src: WH,OD,RS · rec: ⛔ · 🔒 · ReviOS reverted: breaks `defrag c: -b` (boot optimize). See perf.prefetch. Winhance suggests on SSD only
- [ ] **svc.wsearch** — Windows Search indexer (WSearch): set Manual or Disabled · risk: high · src: WH,RS · rec: ⚠️ · 🔒 · Breaks Outlook/Start/Explorer search speed. Compare perf.search-indexing-power
- [ ] **svc.spooler** — Print Spooler: set Manual or Disabled if you have no printer · risk: high · src: WH,RS · rec: ➕ · 🔒 · Printing (incl. PDF printers) stops; PrintNightmare-style attack surface reduced
- [ ] **svc.fax** — Fax service: set Disabled · risk: low · src: WH,OD,RS · rec: ➕ · 🔒 · Fax is an optional feature; rarely present
- [x] **svc.remote-registry** — Remote Registry service: set Disabled · risk: low · src: OD,RS · rec: ✅ · 🔒 · Security hardening; breaks remote regedit/admin tools
- [ ] **svc.bluetooth** — Bluetooth Support Service (bthserv): set Manual/Disabled · risk: med · src: RS · rec: ⚠️ · 🔒 · Only on desktops without Bluetooth peripherals; OD keeps BthAvctpSvc/BthHFSrv Automatic
- [ ] **svc.xbox-services** — Xbox Live Auth, Game Save, Networking (XblAuthManager, XblGameSave, XboxNetApiSvc): Disabled; XboxGipSvc left alone · risk: med · src: WH,OD · rec: ➕ · 🔒 · Breaks Game Pass/Store game sign-in and cloud saves; WH default Manual; OD keeps Manual
- [ ] **svc.cdp-connected-devices** — Connected Devices Platform (CDPSvc, CDPUserSvc): set Disabled · risk: med · src: WH · rec: ➕ · 🔒 · Breaks Nearby Sharing, Phone Link, Dynamic Lock; relevant since cross-device is removed
- [ ] **svc.geolocation-maps** — Geolocation (lfsvc) Disabled; Downloaded Maps Manager (MapsBroker) Manual · risk: low · src: WU,WH,OD · rec: ➕ · 🔒 · lfsvc: location-dependent apps stop working. See privacy group
- [ ] **svc.winutil-set** — winutil set: CscService Disabled, SharedAccess (ICS) Disabled, StorSvc Manual, MapsBroker Manual · risk: med · src: WU · rec: ⚠️ · 🔒 · SharedAccess off breaks Mobile Hotspot/ICS; StorSvc Manual affects Storage Sense/cache
- [ ] **svc.retail-demo** — Retail Demo service (RetailDemo): set Disabled · risk: low · src: WH,OD · rec: ➕ · 🔒
- [ ] **svc.smartcard** — Smart card services (SCardSvr, ScDeviceEnum, SCPolicySvc): set Disabled · risk: med · src: WH · rec: ➕ · 🔒 · Breaks smart cards/YubiKey PIV and some enterprise VPN/login
- [ ] **svc.phone-nfc-sms** — Phone, Wallet, NFC/SE Manager, SMS Router (PhoneSvc, WalletService, SEMgrSvc, SmsRouter): Disabled · risk: low · src: WH · rec: ➕ · 🔒
- [ ] **svc.mixed-reality** — Windows Mixed Reality OpenXR service (MixedRealityOpenXRSvc): Disabled · risk: low · src: WH · rec: ➕ · 🔒 · Breaks WMR/OpenXR headsets
- [ ] **svc.wmp-network-sharing** — WMP Network Sharing (WMPNetworkSvc): set Disabled · risk: low · src: WH,RS · rec: ➕ · 🔒
- [ ] **svc.parental-controls** — Parental Controls service (WpcMonSvc): set Disabled · risk: low · src: WH · rec: ➕ · 🔒 · Breaks Family Safety
- [ ] **svc.biometric** — Windows Biometric Service (WbioSrvc): set Disabled · risk: high · src: WH · rec: ⚠️ · 🔒 · Breaks Windows Hello fingerprint/face; desktops without biometric hardware only
- [ ] **svc.sensors** — Sensor Monitoring and Sensor Data services (SensrSvc, SensorDataService): Disabled · risk: low · src: WH · rec: ➕ · 🔒 · Desktops only; breaks auto-rotate/ambient brightness
- [ ] **svc.telephony** — Telephony service (TapiSrv): set Disabled · risk: med · src: WH · rec: ⚠️ · 🔒 · Leave Manual unless no modem/softphone/Phone Link audio
- [ ] **svc.remote-desktop** — Remote Desktop services (TermService, SessionEnv, UmRdpService): set Disabled · risk: med · src: WH,OD · rec: ➕ · 🔒 · Breaks inbound RDP; WH recommends Manual, OD keeps Manual
- [ ] **svc.ras-vpn** — Remote Access Connection/Auto Connection managers (RasMan, RasAuto): Disabled · risk: high · src: WH · rec: ⚠️ · 🔒 · Breaks built-in VPN and some third-party VPN clients
- [ ] **svc.mobile-hotspot** — Windows Mobile Hotspot service (icssvc): set Disabled · risk: low · src: WH · rec: ➕ · 🔒 · Breaks Mobile Hotspot
- [ ] **svc.tablet-input** — Touch Keyboard and Handwriting service (TabletInputService) Disabled plus IsInputAppPreloadEnabled=0 · risk: med · src: WH,RS · rec: ⚠️ · 🔒 👤 · Breaks emoji panel (Win+.), touch keyboard, pen
- [ ] **svc.spot-verifier** — Spot Verifier (svsvc): Manual (already default) · risk: low · src: WH · rec: ➕ · 🔒 · No change on default Windows
- [ ] **svc.legacy-disabled-od** — OD disable list: AJRouter, AppVClient, AssignedAccessManagerSvc, DialogBlockingService, HomeGroup*, NetTcpPortSharing, RemoteAccess, UevAgentService, shpamsvc, ssh-agent, tzautoupdate · risk: med · src: OD · rec: ➕ · 🔒 · ssh-agent and tzautoupdate (auto timezone) are user-visible; rest unused
- [x] **svc.ai-fabric** — Windows AI Fabric service (WSAIFabricSvc): set Disabled · risk: low · src: WU,WH · rec: ✅ · 🔒 · Complements AI group (Copilot/Recall removal)
- [ ] **svc.onesyncsvc** — OneSyncSvc (mail/contacts/calendar sync) disabled · risk: low · src: WU · rec: ➕ · 🔒 · Companion to OneDrive removal; breaks Mail/Calendar sync
- [ ] **svc.wpn-services** — Windows Push Notification user services (Wpn*): set Disabled · risk: med · src: OD(RT) · rec: ⚠️ · 🔒 · Same as the notifications "aggressive off" mode; kills all toasts
- [ ] **svc.ctfmon-input** — Text Input Management service via ctfmon (InputServiceEnabled=0, ServiceDll swap) · risk: high · src: OD(RT) · rec: ⚠️ · 🔒 · Can break IME, touch keyboard, emoji panel
- [ ] **svc.svchost-split** — Service host grouping: SvcHostSplitThresholdInKB tuned to merge svchost processes · risk: med · src: RV,WU,WH,OD · rec: ➕ · 🔒 ♻ · ReviOS uses revitool "recommended" mode (per-service SvcHostSplitDisable keeps XboxGipSvc working); raw RAM-sized threshold reverted
- [ ] **svc.services-pipe-timeout** — ServicesPipeTimeout from 60 s to 30 s · risk: med · src: WH · rec: ➕ · ♻ · Slow services may then fail to start at boot
- [ ] **svc.tm-monitoring** — Graphics/network telemetry monitors (GraphicsPerfSvc, Ndu, DPS) set Disabled · risk: med · src: OD(RT) · rec: ⛔ · 🔒 · ReviOS reverted: Ndu=2, GraphicsPerfSvc=3, DPS=2 (DPS needed for Data Usage page and Task Manager network)
- [ ] **svc.bam** — Background Activity Moderator (bam) set Disabled · risk: med · src: RV(reverted) · rec: ⛔ · 🔒 · Disabling breaks Efficiency Mode; ReviOS reverted to 1
- [ ] **svc.beep** — Beep driver set Disabled · risk: low · src: RV(reverted) · rec: ⛔ · 🔒 · ReviOS reverted to 1
- [ ] **svc.od-bulk-profile** — OD ~190-service start-type baseline table (mostly Manual, Disabled list above) · risk: high · src: OD · rec: ⛔ · 🔒 · Resets WerSvc/PcaSvc/DiagTrack-adjacent services to Manual, conflicts with svc.reviOS-service-set; table in mech file
- [x] **svc.msi-safeboot** — Allow Windows Installer (MSIServer) to run in Safe Mode · risk: low · src: RV · rec: ✅ · SafeBoot Minimal/Network keys

## Scheduled Tasks

- [x] **task.application-experience** — Disable Application Experience tasks (AitAgent, Compatibility Appraiser, ProgramDataUpdater, MareBackup, StartupAppTask, PcaPatchDbTask) · risk: low · src: RV,WH,OD · rec: ✅ · RV only does AitAgent+Appraiser; others from WH/OD
- [x] **task.ceip** — Disable Customer Experience Improvement Program tasks (Consolidator, UsbCeip, KernelCeipTask) · risk: low · src: RV,WH,OD · rec: ✅
- [x] **task.wer-queue** — Disable Windows Error Reporting QueueReporting task · risk: low · src: RV,WH,OD · rec: ✅ · pairs with svc.wersvc
- [x] **task.disk-diagnostic** — Disable DiskDiagnostic data collector (and OD's Resolver) tasks · risk: low · src: RV,WH,OD · rec: ✅
- [x] **task.diagnosis-scheduled** — Disable \Diagnosis\Scheduled task (scheduled maintenance diagnostics) · risk: low · src: OD · rec: ➕
- [x] **task.power-efficiency** — Disable Power Efficiency Diagnostics AnalyzeSystem task · risk: low · src: RV,WH · rec: ✅
- [x] **task.memory-diagnostic** — Disable MemoryDiagnostic ProcessMemoryDiagnosticEvents and RunFullMemoryDiagnostic tasks · risk: low · src: RV · rec: ✅
- [x] **task.feedback-siuf** — Disable Feedback\Siuf DmClient and DmClientOnScenarioDownload tasks · risk: low · src: WH,OD · rec: ✅
- [x] **task.sqm** — Disable PI\Sqm-Tasks (software quality metrics) task · risk: low · src: WH · rec: ✅
- [x] **task.office** — Disable all scheduled tasks under \Microsoft\Office\ (telemetry, Office Actions Server AI) · risk: low · src: RV,WH · rec: ✅ · WH names only Office Actions Server
- [ ] **task.update-orchestrator** — Disable UpdateOrchestrator tasks (StartOobeAppsScanAfterUpdate, Start Oobe Expedite Work, Schedule Scan) · risk: med · src: RV · rec: ⚠️ · 🔁 · Schedule Scan off = no automatic update scans; conflicts with upd.* policy choices
- [ ] **task.wu-scheduled-start** — Disable WindowsUpdate\Scheduled Start task · risk: med · src: RV · rec: ⚠️ · 🔁 · Part of ReviOS update blocking; review with upd group
- [x] **task.ucpd-velocity** — Disable AppxDeploymentClient\UCPD velocity task · risk: low · src: RV · rec: ✅ · 🔁 · Pair with svc.ucpd, else task re-enables driver
- [ ] **task.autochk-proxy** — Disable Autochk\Proxy (SQM disk-check data) task · risk: low · src: WH,OD · rec: ➕ · Source notes keeping it for disk health data
- [ ] **task.maps-update** — Disable Maps\MapsUpdateTask · risk: low · src: WH,OD · rec: ➕
- [ ] **task.family-safety** — Disable Shell\FamilySafetyMonitor task · risk: low · src: WH · rec: ➕
- [x] **task.windows-ai-recall** — Disable WindowsAI RecallConfiguration and RecallPipeline tasks · risk: low · src: WH · rec: ✅ · Redundant if Copilot+Recall removal (ai group) already applied
- [x] **task.etw-diagnostic-channels** — Turn off SleepStudy, Kernel-Processor-Power and UserModePowerService diagnostic ETW channels · risk: low · src: RV · rec: ✅ · wevtutil, not a task
- [ ] **task.ngen-run-once** — Run .NET Framework NGEN tasks once to flush the queue (not disabled) · risk: low · src: RV · rec: ➕
- [ ] **task.reg-idle-backup** — Re-enable automatic registry backup (EnablePeriodicBackup=1) and create daily AutoRegBackup task · risk: low · src: WU · rec: ➕ · Adds a task rather than removing one

## Performance

- [x] **perf.win32-priority-separation** — Win32PrioritySeparation=38 (short variable quantum, 3x foreground boost) · risk: low · src: RV,OD,WH · rec: ✅ · 38 is WH's "Programs" option; 24 = background services
- [x] **perf.mmcss-tuning** — MMCSS multimedia scheduler: SystemResponsiveness=10, Games task Priority/Scheduling/GPU Priority, NoLazyMode/AlwaysOn · risk: low · src: OD,WH,RV · rec: ➕ · RV only sets NetworkThrottlingIndex=10 (default); OD sets 0xFFFFFFFF
- [x] **perf.network-throttling-index** — NetworkThrottlingIndex: RV 10 (default), OD 0xFFFFFFFF (off) · risk: low · src: RV,OD · rec: ➕ · Conflicts: pick one value; also in mmcss item
- [ ] **perf.memory-compression-off** — Disable-MMAgent -mc · risk: med · src: RV,RT · rec: ➕ · Saves CPU, costs RAM on low-memory machines
- [x] **perf.ntfs-last-access-off** — NTFS last-access timestamp updates disabled (fsutil disableLastAccess 1) · risk: low · src: RV,RT · rec: ✅
- [ ] **perf.ntfs-8dot3-off** — NTFS 8.3 short name creation disabled (fsutil disable8dot3 1) · risk: low · src: RV,RT · rec: ➕ · Can break very old installers
- [ ] **perf.ntfs-memory-usage** — NTFS memory usage high (fsutil memoryusage 2) · risk: low · src: RT · rec: ➕
- [x] **perf.superfetch-keep** — Keep SysMain/Superfetch enabled (revitool superfetch enable) · risk: low · src: RV · rec: ✅ · Not a change from default; documents the ReviOS revert (defrag -b needs it)
- [ ] **perf.prefetch** — EnablePrefetcher=0 (Prefetch off) · risk: low · src: WH,OD · rec: ⛔ · Conflicts perf.superfetch-keep; mainly HDD benefit otherwise
- [x] **perf.ifeo-perfoptions** — IFEO PerfOptions, safe subset: SearchIndexer and ctfmon CPU BelowNormal, fontdrvhost Idle (lsass/sihost Idle deliberately excluded) · risk: low · src: RV · rec: ➕ · 🔒 · Narrowed by user decision; ReviOS also sets lsass/sihost Idle, which can hurt responsiveness.
- [x] **perf.shutdown-timeouts** — Fast shutdown: AutoEndTasks=1, HungAppTimeout/WaitToKillAppTimeout=2000, LowLevelHooksTimeout=1000, WaitToKillServiceTimeout=1500 · risk: med · src: RV · rec: ✅ · 👤 · Can truncate saves at shutdown
- [x] **perf.menu-responsiveness** — MenuShowDelay=0, ActiveWndTrkTimeout=10 · risk: low · src: RV,OD,WH · rec: ✅ · 👤 · MouseHoverTime reverted to 400 by ReviOS (1 ms overlaps tooltips)
- [ ] **perf.mouse-hover-time** — MouseHoverTime lowered (WH 1 ms) · risk: low · src: WH · rec: ⛔ · 👤 · ReviOS reverted to 400: overlapping tooltips
- [ ] **perf.keyboard-latency** — KeyboardDelay=0, KeyboardSpeed=31 · risk: low · src: OD,WU · rec: ➕ · 👤
- [ ] **perf.disable-accessibility-hotkeys** — Disable Sticky/Filter/Toggle Keys hotkey popups · risk: med · src: OD · rec: ➕ · 👤 · Breaks accessibility shortcuts for those who need them
- [ ] **perf.startup-delay** — Remove startup app delay (Serialize StartupDelayInMSec=0) · risk: low · src: OD,WH · rec: ➕ · 👤
- [ ] **perf.visual-effects** — Visual effects best performance: UserPreferencesMask, MinAnimate, TaskbarAnimations, ListviewAlphaSelect/Shadow, DragFullWindows, AeroPeek · risk: low · src: WU,WH · rec: ➕ · 👤 · Overlaps look.* items; WH exposes 20 individual toggles
- [ ] **perf.background-apps-off** — Background apps off (GlobalUserDisabled, LetAppsRunInBackground=2) · risk: med · src: OD,RT,WH · rec: ⛔ · 👤 · ReviOS reverted: broke Xbox Game Bar Known Game List update
- [x] **perf.explorer-folder-discovery-off** — Disable automatic folder type discovery (FolderType=NotSpecified) · risk: low · src: RV,WU · rec: ✅ · 👤 · Needs sign-out; resets view bags
- [ ] **perf.explorer-downloads-no-groupby** — Remove GroupBy in Downloads folder type · risk: low · src: RV · rec: ➕ · 🔒 👤  **DEFERRED: the FolderTypes GroupBy location is not documented in the inventories; needs a check on a live system.**
- [x] **perf.explorer-high-perf-gpu** — Explorer uses high-performance GPU (UserGpuPreferences GpuPreference=2) · risk: low · src: RV · rec: ➕ · 👤 · Laptops with hybrid graphics: battery cost
- [x] **perf.search-indexing-power** — Search indexing respects power modes; no indexing on battery · risk: low · src: RV · rec: ✅
- [x] **perf.disable-low-disk-checks** — NoLowDiskSpaceChecks=1 · risk: low · src: RV · rec: ➕ · 👤
- [x] **perf.no-track-shortcuts** — LinkResolveIgnoreLinkInfo=1 and NoResolveSearch=1 (stop shell shortcut tracking) · risk: low · src: RV · rec: ✅ · 👤
- [x] **perf.disable-autochk** — Disable boot-time autochk (BootExecute autocheck autochk /k:C*) · risk: med · src: RV · rec: ➕ · No automatic chkdsk after unclean shutdown
- [x] **perf.disable-wpbt** — DisableWpbtExecution=1 (stop OEM firmware injecting binaries at boot) · risk: low · src: RV · rec: ✅
- [ ] **perf.auto-maintenance-off** — Automatic Maintenance disabled (MaintenanceDisabled=1, ScheduledDiagnostics EnabledExecution=0) · risk: med · src: RV · rec: ➕ · ReviOS option, default OFF; user did not choose it
- [ ] **perf.restore-point-config** — Remove System Restore pre-defined config (SPP clients, RPSessionInterval=0, DiskPercent=0) · risk: med · src: RV · rec: ⚠️ · Does not disable System Restore; WH separately toggles Enable-ComputerRestore
- [x] **perf.reserved-storage-off** — Reserved Storage disabled (ShippedWithReserves=0, Set-WindowsReservedStorageState) · risk: low · src: RV · rec: ➕ · 🔁 · Frees ~7 GB; Windows Update may re-enable
- [ ] **perf.storage-sense-off** — Storage Sense disabled (policy AllowStorageSenseGlobal=0 / StoragePolicy 01=0) · risk: low · src: WU,WH · rec: ➕ · 👤
- [ ] **perf.long-paths** — Enable Win32 long paths (LongPathsEnabled=1) · risk: low · src: WU · rec: ➕
- [ ] **perf.ngen-powershell** — Precompile PowerShell assemblies with ngen · risk: low · src: RV · rec: ➕ · One-shot  **DEFERRED: ReviOS ngen script compiles whatever the host process has loaded (no checkable end state).**
- [ ] **perf.disk-cleanup-oneshot** — One-shot cleanmgr plus log, SoftwareDistribution and temp purge · risk: med · src: RV,WU · rec: ➕ · Wipes SoftwareDistribution and event logs; WU only clears temp
- [ ] **perf.boot-menu-timeout-0** — bcdedit bootmgr timeout 0 for single-OS systems · risk: low · src: WU · rec: ➕ · Breaks dual-boot menu access
- [ ] **perf.intel-tsx** — Intel TSX enabled (DisableTsx=0) · risk: med · src: RV,RT · rec: ➕ · Security trade-off; only on CPUs that have it
- [ ] **perf.svchost-split-ref** — Service host grouping — see svc.svchost-split · risk: med · src: RV,WU,WH,OD · rec: ⛔ · redundant with svc.svchost-split; listed only for cross-reference
- [ ] **perf.power-throttling-off** — Power Throttling disabled (PowerThrottlingOff=1) · risk: low · src: OD,WH · rec: ➕ · ♻ · Same as pwr.power-throttling-off; breaks Efficiency Mode behaviour of throttling
- [ ] **perf.hags** — Hardware-accelerated GPU scheduling (HwSchMode=2 on / 1 off) · risk: med · src: OD,WH · rec: ⛔ · ReviOS commented out: user had acceleration issues; default is driver-dependent
- [ ] **perf.mpo-off** — Multiplane Overlay off (OverlayTestMode=5) plus optional DisableOverlays=1, OverlayMinFPS=0 · risk: med · src: WU,WH,OD(RT) · rec: ➕ · ♻ · Only for flicker/black-screen fixes; DisableOverlays breaks Steam/Discord overlays
- [ ] **perf.directx-windowed-flip** — Optimizations for windowed games / swap-effect upgrade (DirectXUserGlobalSettings) · risk: low · src: WH,RT · rec: ➕ · 👤 · Also covers VRR and Auto HDR tokens in same string
- [ ] **perf.gpu-nvidia** — NVIDIA driver tweaks: DisableDynamicPstate=1, DisableASyncPstates=1 · risk: med · src: OD · rec: ➕ · 🔒 ♻ · Optional; keeps GPU at high clocks, more heat/power
- [ ] **perf.gpu-amd** — AMD driver tweaks: EnableULPS=0, power/clock gating off, ASPM off · risk: med · src: OD · rec: ➕ · 🔒 ♻ · Optional; raises idle power
- [ ] **perf.gpu-intel** — Intel driver tweaks: Display1_DisableAsyncFlips=1, AdaptiveVsyncEnable=0 · risk: low · src: OD · rec: ➕ · 🔒 ♻
- [ ] **perf.search-webview2** — Disable WebView2 in Windows Search (FeatureManagement override 1694661260) · risk: low · src: WH · rec: ➕ · 🔁 · Undocumented feature ID; also in privacy/start groups
- [ ] **perf.alt-tab-filter** — Alt+Tab shows windows only, no Edge tabs (MultiTaskingAltTabFilter=3) · risk: low · src: WH · rec: ➕ · 👤 · WH default is already 3
- [ ] **perf.webdav-limit** — Lift WebDAV file size limit (FileSizeLimitInBytes=0xFFFFFFFF) · risk: low · src: OD · rec: ➕
- [ ] **perf.wallpaper-quality** — JPEGImportQuality=100 (no wallpaper recompression) · risk: low · src: WH · rec: ➕ · 👤 · WH label says compression enabled but recommended value 100
- [x] **perf.copy-dialog-details** — Show more details in copy dialog (EnthusiastMode=1) · risk: low · src: RV · rec: ✅ · 👤
- [ ] **perf.search-whole-filesystem** — Search entire file system instead of indexed locations (WholeFileSystem=1) · risk: low · src: WH · rec: ⛔ · 👤 · Slower; conflicts with indexing setups

## Gaming

- [x] **game.gamedvr-off** — Game DVR/background capture off (GameDVR_Enabled=0, AppCaptureEnabled=0, AllowGameDVR=0) · risk: low · src: RV,WU,WH,OD · rec: ✅ · 👤 · ReviOS: AppCaptureEnabled=0 only if Xbox removed (else Start Recording greyed, #74)
- [x] **game.gamebar-off** — Xbox Game Bar off (GameBarEnabled=0, ShowStartupPanel=0, UseNexusForGameBarEnabled=0) · risk: low · src: OD,WH · rec: ➕ · 👤 · Breaks Win+G overlay and controller Xbox-button launch
- [x] **game.game-mode** — Game Mode on (AllowAutoGameMode=1, AutoGameModeEnabled=1) · risk: low · src: WU,WH,OD · rec: ✅ · 👤 · Windows default is on
- [ ] **game.fullscreen-optimizations-off** — Disable fullscreen optimizations (GameDVR_FSEBehaviorMode=2 and companion keys) · risk: low · src: RV,WH,OD(RT) · rec: ➕ · 👤 · RV sets FSEBehaviorMode=0 with GameDVR off; WH/OD set 2. Conflicts with perf.directx-windowed-flip
- [x] **game.mouse-accel-off** — Mouse acceleration off (MouseSpeed/Threshold1/Threshold2=0) · risk: low · src: RV,WU,WH,OD · rec: ✅ · 👤
- [ ] **game.raw-mouse-throttle** — Background window message rate limit (RawMouseThrottleEnabled=1, Duration 3..20 ms) · risk: low · src: RT · rec: ➕ · 👤
- [x] **game.vbs-hvci-off** — Disable VBS / Memory Integrity (HVCI) for gaming performance · risk: high · src: RV,OD · rec: ⚠️ · 🔒 ♻ · same as sec.vbs-hvci-off. Security trade-off; ReviOS applies it always
- [x] **game.gaming-copilot-block** — Block Gaming Copilot companion host (GamingCompanionHostOptions ActivationType) · risk: low · src: RV · rec: ✅ · 🔒 · Also relevant to AI group
- [ ] **game.gpu-priority-games** — Games MMCSS task: GPU Priority=8, Priority=6, Scheduling Category=High · risk: med · src: WH,OD · rec: ➕ · Same key set as perf.mmcss-tuning; OD sets Priority=2
- [ ] **game.auto-hdr-vrr** — Auto HDR and Variable Refresh Rate tokens (DirectXUserGlobalSettings) · risk: low · src: WH · rec: ➕ · 👤 · Requires HDR/VRR display
- [ ] **game.auto-color-management** — Automatically manage color for apps (AutoColorManagementEnabled) · risk: low · src: WH · rec: ➕ · ♻
- [ ] **game.desktop-composition-off** — Disable DWM composition (CompositionPolicy=0) · risk: med · src: WH · rec: ⛔ · 👤 · Breaks Aero/transparency; Win11 may ignore
- [ ] **game.nvidia-extras** — NVIDIA legacy sharpening (EnableGR535) and DLSS indicator off (ShowDlssIndicator=0) · risk: low · src: WH,OD · rec: ➕ · 🔒
- [ ] **game.known-game-list-refresh** — Refresh Xbox Known Game List (KGLRevision, KGL OneSettings) so Game Mode/DVR recognise games · risk: low · src: RT · rec: ➕ · 👤 · Network call to settings.data.microsoft.com
- [ ] **game.per-game-mitigations** — Per-game IFEO mitigation fixes (Valorant vgc.exe CFG, osu! ASLR) · risk: low · src: RV · rec: ➕ · 🔒 · Fixes specific games; remove if not used
- [x] **game.boot-timer-defaults** — bcdedit: delete useplatformclock and disabledynamictick (leave timer defaults) · risk: low · src: RV · rec: ✅ · ♻ · ReviOS does not set useplatformtick/disabledynamictick yes: breaks ROG Ally sleep (#167)
- [ ] **game.teredo-off** — Teredo tunnelling off (gaming latency) · risk: low · src: WU · rec: ➕ · Defined in net group; see net.*
- [x] **game.vulnerable-driver-blocklist** — Keep Vulnerable Driver Blocklist enabled (value 1) · risk: low · src: RV · rec: ✅ · ReviOS: setting 0 breaks THE FINALS; process mitigations and Spectre/Meltdown overrides also left default

## Power

- [x] **pwr.hibernate-off** — Disable hibernation and Fast Startup (powercfg -h off, HibernateEnabled=0, HiberbootEnabled=0, ShowHibernateOption=0) · risk: med · src: RV,RT,WU,WH,OD · rec: ✅ · ReviOS default; laptop sleep may overheat. Radio vs enable-hibernate.
- [ ] **pwr.fast-startup-off-only** — Disable Fast Startup only (HiberbootEnabled=0, keep hibernate) · risk: low · src: RT,WH,OD · rec: ⛔ · Redundant with pwr.hibernate-off; use only if you want hibernation kept
- [x] **pwr.high-performance-plan** — Revision "Ultra Performance" power plan (Ultimate Performance duplicate, tuned) · risk: med · src: RV,RT,WU · rec: ➕ · 🔒 · Not for laptops; WU uses stock Ultimate Performance GUID. OD's embedded .pow is not captured
- [x] **pwr.plan-c6-disable** — Revi plan: deep idle C6 disabled (idle promote/demote 100/80) · risk: low · src: RT · rec: ➕ · 🔒 · Only applies to the Revision plan
- [ ] **pwr.display-sleep-timeouts** — Display, disk and sleep timeouts (display/disk/sleep idle = never on AC, wake timers off) · risk: low · src: WH · rec: ➕ · WH recommended: AC 0, DC 300/600/900 s
- [ ] **pwr.usb-selective-suspend** — USB selective suspend, hub timeout and USB3 link power management off (+ per-device MSPower flag) · risk: low · src: WH,OD,RV · rec: ➕ · ReviOS plan also disables USB3 LPM; OD adds AttemptRecoveryFromUsbPowerDrain=0
- [ ] **pwr.pcie-aspm-off** — PCIe Link State Power Management off on AC (ASPM=0) · risk: low · src: WH · rec: ➕ · More idle power, fewer GPU/NVMe latency spikes
- [ ] **pwr.processor-states** — CPU min/max state, boost mode, core parking, EPP, increase/decrease policy and thresholds · risk: low · src: WH,RT · rec: ➕ · Settings listed in mech; ReviOS plan sets core parking 100, PERFINCPOL=2, PERFDECPOL=1
- [ ] **pwr.power-throttling-off** — Power Throttling disabled (PowerThrottlingOff=1) · risk: low · src: OD,WH · rec: ➕ · ♻ · Same as perf.power-throttling-off; apply once
- [ ] **pwr.sleep-states** — Sleep state behaviour: Modern Standby (S0) off via PlatformAoAcOverride=0 / S3 · risk: high · src: WU,RT · rec: ⚠️ · ♻ · Needs hardware S3 support; also WU "S0 network connectivity" toggle
- [ ] **pwr.hybrid-sleep-hibernate-timeouts** — Hybrid sleep off, hibernate-after timeout 0 · risk: low · src: WH · rec: ➕ · Moot when pwr.hibernate-off applied
- [ ] **pwr.button-lid-actions** — Power button, sleep button and lid close actions (unhidden power options) · risk: low · src: WH · rec: ➕ · Laptop-oriented
- [x] **pwr.start-power-menu** — Start power menu: show Sleep (ShowSleepOption=1), Lock, Hibernate · risk: low · src: RV,WH · rec: ✅ · ReviOS shows Sleep
- [x] **pwr.shutdown-without-logon** — Allow shutdown from logon screen (ShutdownWithoutLogon=1) · risk: low · src: RV · rec: ✅
- [x] **pwr.logon-polish** — Disable first sign-in animation and startup sound (EnableFirstLogonAnimation=0, DisableStartupSound=1) · risk: low · src: RV · rec: ✅
- [x] **pwr.crash-control** — Auto-reboot after BSOD off, small memory dump (AutoReboot=0, CrashDumpEnabled=3) · risk: low · src: RV · rec: ✅
- [ ] **pwr.gpu-power-plan-settings** — Intel graphics, AMD slider overlay, ATI PowerPlay, switchable-graphics preference power settings · risk: low · src: WH · rec: ➕ · Hardware-specific; laptops only
- [ ] **pwr.multimedia-battery** — Multimedia power: sharing media, video playback quality bias, when playing video, JS timer, slideshow, wireless power mode · risk: low · src: WH · rec: ➕
- [ ] **pwr.battery-levels** — Low/critical/reserve battery levels, notifications and actions · risk: low · src: WH · rec: ➕ · Laptops only
- [ ] **pwr.battery-percentage-tray** — Show battery percentage in tray · risk: low · src: OD · rec: ➕ · 👤
- [x] **pwr.hello-logon-fix** — Delete DisableAutomaticRestartSignOn (fixes slow Windows Hello logon) · risk: low · src: RV · rec: ✅ · Revert-style fix; ReviOS always applies

## Explorer & Shell

- [x] **shell.show-file-extensions** — Show file extensions: show .ext on all files (HideFileExt=0) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · ReviOS lists it under Security
- [x] **shell.show-hidden-files** — Show hidden files, folders and drives (Hidden=1) · risk: low · src: WU,OD,WH · rec: ➕ · 👤
- [ ] **shell.show-protected-os-files** — Show protected operating-system files (ShowSuperHidden=1) · risk: med · src: WH · rec: ⚠️ · 👤 · Easy to delete system files by accident
- [ ] **shell.show-lnk-extension** — Show .lnk extension on shortcuts when extensions are on · risk: low · src: WH · rec: ➕ · 🔒 · HKCR key; spots disguised shortcuts; some Start entries then show ".lnk"
- [x] **shell.launch-to-this-pc** — Open File Explorer to This PC instead of Home (LaunchTo=1) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤
- [x] **shell.hide-home-gallery** — Remove Home and Gallery nodes from the Explorer navigation pane · risk: low · src: WU,OD,WH · rec: ➕ · 👤 · WH also sets HKLM NonEnum/HiddenByDefault
- [ ] **shell.hide-network-navpane** — Hide Network node in Explorer navigation pane · risk: low · src: — · rec: ➕ · 🔒 · No inventory source; mechanism unverified, see mech file
- [x] **shell.recent-files-off** — Stop Quick Access recent files, recommendations and Office.com cloud files · risk: low · src: WH · rec: ➕ · 👤 · Different from Start-menu recent lists
- [x] **shell.frequent-folders-off** — Stop Quick Access frequent folders (ShowFrequent=0) · risk: low · src: WH · rec: ➕ · 👤
- [ ] **shell.navpane-options** — Nav-pane tweaks: expand to current folder, show all folders, Libraries, cloud status, user folders · risk: low · src: WH · rec: ➕ · 👤🔒 · Mixed HKCU and HKLM keys
- [x] **shell.this-pc-folders-hide** — Hide Desktop/Documents/Downloads/Music/Pictures/Videos folders under This PC · risk: low · src: WH · rec: ➕ · 🔒 · HKLM MyComputer NameSpace HiddenByDefault
- [ ] **shell.compact-view** — Compact Explorer view: decrease spacing between items (UseCompactMode=1) · risk: low · src: OD,WH · rec: ➕ · 👤
- [ ] **shell.item-checkboxes** — Checkboxes to select items in Explorer (AutoCheckSelect=1) · risk: low · src: OD,WH · rec: ➕ · 👤
- [x] **shell.full-path-title** — Show full folder path in Explorer title bar (FullPath=1) · risk: low · src: RV,WH · rec: ✅ · 👤
- [x] **shell.sync-provider-notifications-off** — Turn off OneDrive/sync-provider ads and banners in Explorer · risk: low · src: RV,OD,WH · rec: ✅ · 👤 · Complements removing OneDrive
- [x] **shell.info-tips-off** — Disable pop-up descriptions for folder and desktop items (ShowInfoTip=0) · risk: low · src: RV,WH · rec: ✅ · 👤 · WH exposes it only as a toggle, ReviOS forces off
- [x] **shell.shortcut-suffix-off** — Remove " - Shortcut" suffix from newly created shortcuts · risk: low · src: RV,WH · rec: ✅ · 👤
- [ ] **shell.shortcut-arrow-remove** — Remove arrow overlay from shortcut icons via blank .ico · risk: low · src: OD,WH · rec: ➕ · 🔒 · Needs a blank.ico shipped; HKLM
- [ ] **shell.desktop-icons** — Show This PC / Recycle Bin / User Files / Network / Control Panel on desktop; or hide all icons · risk: low · src: OD,WH · rec: ➕ · 👤
- [x] **shell.hide-spotlight-desktop-icon** — Hide "Learn about this picture" Spotlight desktop icon (24H2) · risk: low · src: RV · rec: ✅ · 🔒 · Value is HKLM; also see look.spotlight-lockscreen-off
- [ ] **shell.explorer-window-behavior** — Separate process per window, restore windows at logon, folder-open and click behaviour · risk: low · src: WH · rec: ➕ · 👤
- [ ] **shell.view-misc** — Misc view options: status bar, drive letters first, empty drives, folder tips, type-ahead, merge conflicts · risk: low · src: WH · rec: ➕ · 👤 · Individual values listed in mech
- [ ] **shell.thumbnails-icons-only** — Always show icons, never thumbnails (IconsOnly=1) · risk: low · src: WH · rec: ➕ · 👤 · Also in WH Performance as opposite toggle; picks conflict with look.visual-effects
- [ ] **shell.icon-thumbnail-cache** — Larger icon cache (MaxCachedIcons) and keep thumbnail cache through disk cleanup · risk: low · src: WH · rec: ➕ · 🔒 · HKLM
- [ ] **shell.photo-viewer-restore** — Restore classic Photo Viewer and map image extensions to it · risk: low · src: RV,WH · rec: ➕ · 🔒 · Tie to appx Photos removal; ReviOS applies only when Photos removed  **DUPLICATE: implemented as misc.classic-photo-viewer (ticked).**
- [ ] **shell.legacy-notepad** — Use legacy Notepad as handler: NoOpenWith removal and disable Store Notepad redirect · risk: low · src: WH · rec: ➕ · 🔒 · Needs Notepad (Legacy) capability installed
- [x] **shell.tablet-mode-desktop** — Always use desktop mode, never tablet mode prompts (SignInMode, TabletMode) · risk: low · src: RV · rec: ➕ · 👤 · Irrelevant on non-convertible PCs
- [ ] **shell.scrollbars-always-visible** — Disable auto-hiding (dynamic) scrollbars · risk: low · src: WU · rec: ➕ · 👤
- [ ] **shell.window-snap-settings** — Window snapping, Aero Shake off, Snap Assist flyout off · risk: low · src: WU,OD · rec: ➕ · 👤
- [ ] **shell.numlock-on** — Num Lock on at logon and boot (InitialKeyboardIndicators=2) · risk: low · src: WU,OD · rec: ➕ · 👤 · Write to HKU\.DEFAULT too so it applies at logon screen
- [ ] **shell.capslock-disable** — Disable Caps Lock key via Scancode Map · risk: low · src: OD · rec: ➕ · 🔒 ♻ · Revitool CLI feature; HKLM binary
- [ ] **shell.clipboard-history** — Enable clipboard history (Win+V) · risk: low · src: OD · rec: ➕ · 👤 · Privacy trade-off: history stays local
- [ ] **shell.settings-home-hide** — Hide Settings app Home page (SettingsPageVisibility=hide:home) · risk: low · src: WU · rec: ➕ · 👤 · Will conflict with any other SettingsPageVisibility write; merge lists
- [ ] **shell.toast-notifications-off** — Turn off toast notifications and Notification Center (minimal or full mode) · risk: med · src: WU,OD,WH · rec: ⚠️ · 👤 · Kills Calendar flyout; "full" also disables Wpn* services
- [ ] **shell.edge-swipe-off** — Disable touchscreen edge swipe (AllowEdgeSwipe=0) · risk: low · src: OD · rec: ➕ · 🔒 · HKLM policy; touch devices only
- [ ] **shell.verbose-logon** — Show verbose status messages at logon/logoff (VerboseStatus=1) · risk: low · src: WU,OD · rec: ➕ · 🔒
- [ ] **shell.detailed-bsod** — Show detailed BSOD parameters, disable sad emoticon · risk: low · src: WU · rec: ➕ · 🔒
- [ ] **shell.time-utc** — Hardware clock is UTC (RealTimeIsUniversal=1) · risk: med · src: WU · rec: ⚠️ · 🔒 · Only for Windows+Linux dual boot
- [ ] **shell.long-paths** — Enable Win32 long paths (LongPathsEnabled=1) · risk: low · src: WH · rec: ➕ · 🔒 · May also appear under Performance/Misc; dedupe on merge
- [ ] **shell.default-printer-management-off** — Stop Windows auto-switching default printer (LegacyDefaultPrinterMode=1) · risk: low · src: WH · rec: ➕ · 👤
- [x] **shell.cross-device-resume-block** — Block Cross Device Resume host and policy · risk: low · src: RV · rec: ➕ · 🔒 · Tied to Your Phone removal; likely also listed in the Appx/Features group

## Start Menu & Taskbar

- [x] **start.remove-pinned-items** — Replace default Start pins with Store, Settings, Notepad, Paint, Explorer, Calculator; purge caches · risk: med · src: RV,WU,WH · rec: ✅ · 🔒 · ConfigureStartPins on Pro 24H2 unverified; WU Start layout fails on 25H2+; WH needs HKLM GPO key too
- [ ] **start.default-user-layout** — Seed Start/taskbar layout for new accounts via Default profile · risk: med · src: RV,WU,WH · rec: ➕ · 👤🔒 · HKU\.DEFAULT is not the new-user template; load Default NTUSER.DAT instead
- [x] **start.pinned-folders-hidden** — Hide Documents/Downloads/Music/etc. folder shortcuts next to Start power button · risk: low · src: RV · rec: ✅ · 🔒 · Settings stays shown
- [x] **start.recommendations-account-notifs-off** — Turn off Start Iris recommendations and account notifications · risk: low · src: RV,WH · rec: ✅ · 👤
- [ ] **start.hide-recommended-section** — Hide Start Recommended section (HideRecommendedSection plus IsEducationEnvironment) · risk: med · src: WU,OD,WH · rec: ➕ · 🔒 · Side effect: Spotlight lock screen stops; IsEducationEnvironment hack alters SKU behaviour
- [ ] **start.layout-lists-prefs** — Start layout (more pins), All-apps view, recent/most-used app lists, recent files · risk: low · src: WH · rec: ➕ · 👤 · All-apps view needs build 26100.7171
- [x] **start.taskbar-search-mode** — Taskbar search box: hidden / icon only / icon+label / box · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · ReviOS = icon only (1); WU/WH = hidden (0)
- [ ] **start.web-search-off** — Disable Bing/web results in Start search (BingSearchEnabled=0, DisableSearchBoxSuggestions=1) · risk: low · src: RV,OD,WH · rec: ✅ · 👤 · BingSearchEnabled also needed on 25H2+
- [x] **start.cortana-cloud-search-off** — Windows Search policy: cloud search, Cortana, web search, location off · risk: low · src: RV · rec: ✅ · 🔒 · ReviOS sets AllowCortana=1 (sic) despite comment
- [ ] **start.search-store-results-off** — Block Store results in Search (WinStore.Tasks.WindowsSearchTask) · risk: low · src: RV · rec: ➕ · 🔒 · 25H2 only
- [ ] **start.searchhost-webview2-block** — FeatureManagement overrides stop SearchHost spawning WebView2 · risk: med · src: RV · rec: ⚠️ · 🔒🔁 · Undocumented feature IDs
- [x] **start.task-view-off** — Hide Task View button (ShowTaskViewButton=0) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤
- [x] **start.widgets-off** — Disable Widgets and News/Interests: policies, TaskbarDa=0 · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤🔒 · AllowNewsAndInterests=0 stops WebExperience reinstall; appx removal handled in Appx group
- [x] **start.chat-meetnow-off** — Hide taskbar Chat (Teams), Meet Now and People bar · risk: low · src: RV,WU,OD · rec: ✅ · 👤🔒 · Meet Now/People are mostly Win10 leftovers
- [ ] **start.taskbar-alignment-left** — Align taskbar icons left (TaskbarAl=0) · risk: low · src: WU,OD,WH · rec: ➕ · 👤
- [x] **start.end-task** — Add "End task" to taskbar right-click menu · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤
- [ ] **start.notification-area-cleanup** — Stop notification-area auto-cleanup and balloon feature ads (NoAutoTrayNotify, NoBalloonFeatureAdvertisements) · risk: low · src: RV · rec: ✅ · 👤 · Policy keys under HKCU
- [ ] **start.tray-icons-show-all** — Show all system tray icons instead of overflow · risk: low · src: WH · rec: ➕ · 👤 · Sets SystemTrayChevronVisibility and per-icon IsPromoted
- [ ] **start.tray-clock-battery** — Seconds in clock, battery percentage in tray · risk: low · src: WU,OD · rec: ➕ · 👤
- [ ] **start.taskbar-behavior** — Button grouping, auto-hide and delay, badges, flashing, multi-monitor, show-desktop corner, icon size · risk: low · src: OD,WH · rec: ➕ · 👤 · Individual values in mech
- [ ] **start.clean-taskbar-pins** — Remove all taskbar pins (Taskband Favorites) · risk: low · src: WU,WH · rec: ➕ · 👤 · Per existing user; for new users use start.default-user-layout
- [ ] **start.old-start-layout** — Revert to previous Start layout via FeatureManagement override · risk: med · src: WU · rec: ⛔ · 🔒 · winutil states it does not work on 25H2+

## Appearance

- [x] **look.dark-mode** — Dark mode for system and apps (AppsUseLightTheme=0, SystemUsesLightTheme=0) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · ReviOS also applies dark.theme via Set-Theme.ps1
- [x] **look.transparency-off** — Disable transparency effects (EnableTransparency=0) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · ReviOS bundles MinAnimate=0 here; kept in look.animations-off
- [ ] **look.wallpaper-revision** — Revision wallpapers and lock screen via WALLPAPER.ps1 · risk: low · src: RV · rec: ➕ · 👤🔒 · Needs bundled image assets (branding); user did not choose
- [ ] **look.accent-palette** — Custom accent colour palette and accent colour #0078D4 · risk: low · src: RV,WU · rec: ➕ · 🔒 · RV writes HKLM palette values; WU writes per-user accent keys
- [ ] **look.animations-off** — Minimize/taskbar animations off, VisualFXSetting=3 · risk: low · src: RV,WU,OD · rec: ➕ · 👤 · RV taskbar-animations branch is effectively "delete value"; verify
- [ ] **look.visual-effects** — Disable list shadow, translucent selection, window/pointer shadows, Aero Peek, drag full window · risk: low · src: WU,OD,WH · rec: ➕ · 👤 · Conflicts with nothing but changes UserPreferencesMask binary; collapse many WH toggles
- [x] **look.jpeg-quality-100** — Wallpaper JPEG import quality 100 (no compression) · risk: low · src: RV,WH · rec: ✅ · 👤
- [x] **look.beeps-off** — Turn off system beeps (Sound\Beep=no) · risk: low · src: RV · rec: ✅ · 👤 · Do not disable the Beep service; ReviOS reverted that to Automatic
- [x] **look.startup-sound-off** — Disable startup sound and first-logon animation · risk: low · src: RV,WH · rec: ✅ · 🔒 · Also listed under Power; dedupe on merge
- [x] **look.audio-ducking-off** — Communications ducking = Do nothing (UserDuckingPreference=3) · risk: low · src: RV,WH · rec: ➕ · 👤
- [x] **look.menu-responsiveness** — MenuShowDelay=0, ActiveWndTrkTimeout=10, Explorer startup delay 0 · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · Do not lower MouseHoverTime below 400; ReviOS reverted (overlapping tooltips)
- [x] **look.mouse-accel-off** — Disable Enhance Pointer Precision (MouseSpeed/Threshold1/2 = 0) · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · Also in Gaming group; dedupe on merge
- [ ] **look.keyboard-repeat-max** — Fastest keyboard repeat: KeyboardDelay=0, KeyboardSpeed=31 · risk: low · src: WU,OD · rec: ➕ · 👤
- [ ] **look.cursor-shadow-off** — Disable shadow under mouse pointer (UserPreferencesMask bit) · risk: low · src: WH · rec: ➕ · 👤 · Shares UserPreferencesMask with look.visual-effects; write once
- [x] **look.sticky-keys-prompts-off** — Disable Sticky/Filter/Toggle Keys shortcut popups · risk: low · src: WU,OD,WH · rec: ✅ · 👤 · ReviOS achieves it via look.accessibility-reset
- [ ] **look.accessibility-reset** — Wipe Control Panel\Accessibility subkeys and set all Flags=0 (ReviOS) · risk: med · src: RV · rec: ⚠️ · 👤 · Breaks accessibility hotkeys, high contrast, MouseKeys; not safe for users who need them
- [x] **look.spotlight-lockscreen-off** — Disable Spotlight, lock-screen tips/fun facts, third-party suggestions · risk: low · src: RV,WH · rec: ✅ · 👤🔒 · Overlaps Privacy ContentDeliveryManager item
- [ ] **look.lockscreen-disable** — Skip the lock screen entirely (NoLockScreen=1) · risk: low · src: WU · rec: ➕ · 🔒 · WH DisableLockWorkstation is different (blocks Win+L)
- [ ] **look.logon-blur-off** — Remove acrylic blur on logon screen · risk: low · src: WU · rec: ➕ · 🔒
- [ ] **look.dynamic-lighting-off** — Disable Dynamic Lighting ambient RGB control · risk: low · src: WH · rec: ➕ · 👤 · Only on devices with RGB peripherals

## Context Menu

- [x] **ctx.legacy-menu** — Classic Win10 right-click menu; removes "Show more options" step · risk: low · src: RV,WU,OD,WH · rec: ✅ · 👤 · Needs Explorer restart; default-user mirror for new accounts
- [ ] **ctx.take-ownership** — Add "Take Ownership" for files, folders, DLLs · risk: med · src: RV,WH · rec: ⚠️ · 🔒 · Easy to damage ACLs; ReviOS excludes C:\Users, Windows, Program Files(x86)
- [ ] **ctx.multi-select-limit** — Raise multi-select verb prompt threshold to 100 items · risk: low · src: RV · rec: ➕ · 👤
- [ ] **ctx.compress-to** — Add "Compress to" to classic menu (ZIP, 7z, TAR) · risk: low · src: WH · rec: ➕ · 🔒 · Needs 26100+
- [ ] **ctx.open-terminal** — Show "Open in Terminal" on folders and background · risk: low · src: WH · rec: ➕ · 🔒 · Removes Shell Extensions\Blocked entry
- [ ] **ctx.toggle-extensions-entry** — Add Show/Hide extensions item to context menu · risk: low · src: WH · rec: ➕ · 🔒 · Redundant with shell.show-file-extensions
- [ ] **ctx.utility-entries** — Add SFC /SCANNOW, DISM RestoreHealth, CHKDSK to desktop background menu · risk: low · src: WH · rec: ➕ · 🔒
- [ ] **ctx.ps1-edit-run** — Cascading Edit/Run-with menu for .ps1 files · risk: low · src: WH · rec: ➕ · 🔒
- [x] **ctx.open-with-store-lookup-off** — Remove "Look for an app in the Store" in Open with (NoInternetOpenWith=1) · risk: low · src: RV · rec: ✅ · 👤🔒 · ReviOS sets HKCU and HKLM
- [ ] **ctx.cast-to-device-remove** — Remove "Cast to Device" entry via Shell Extensions Blocked · risk: low · src: — · rec: ➕ · 🔒 · No inventory source; general knowledge, verify GUID
- [ ] **ctx.share-remove** — Remove "Share" entry (ModernSharing) from context menu · risk: low · src: — · rec: ➕ · 🔒 · No inventory source; general knowledge, verify GUID
- [ ] **ctx.sendto-cleanup** — Remove default Send-to entries (Fax, Mail, Documents) · risk: low · src: — · rec: ➕ · 👤 · No inventory source; delete shortcuts in per-user SendTo folder
