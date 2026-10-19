# Review of your selected tweaks (254 ticked in TWEAKS.md)

Checked against the tweak notes (conflicts, risk) and against **this PC's live state** (read-only queries, run without admin, 2026-10-17). Nothing was changed. Some checks (Hyper-V boot flag, DISM features, BitLocker volumes, Defender MP status) need an elevated shell and are marked *unverified*.

## 1. What this PC is

| Fact | Value |
|---|---|
| OS | Windows 11 Pro 24H2, build 26100.7840 (Feb 2026 patch level), region New Zealand |
| Hardware | Desktop (no battery), AMD Ryzen 9 5900X, 3 SSDs |
| Management | Workgroup, not domain/Entra joined, no MDM enrollment. Nothing external will override registry/policy changes |
| Browsers | Firefox is default, Chrome installed, **Edge already gone**, WebView2 present |
| Printers | Two Brother QL-820NWB label printers, 29 Bluetooth devices (so the Spooler and Bluetooth services must stay enabled; neither is ticked) |
| Virtualization | Hyper-V services (`vmms`, `vmcompute`, `hns`), WSL service, Docker Desktop present; `HypervisorPresent=False` right now (*unverified why*) |

### This PC already has ReviOS applied

- Power plan is "Revision - Ultra Performance". Hosts file is the ReviOS blocklist (54 lines, all `0.0.0.0`, **no custom entries**).
- Four Revision CBS packages are installed: **Defender-Removal, AI-Removal, OneDrive-Removal, SystemPackages-Removal** (v2.1.1.0). The `WinDefend`, `Sense` and `WdFilter` services are gone; `MDCoreSvc` is disabled; Defender policies `DisableAntiSpyware/AntiVirus=1`.
- Updates paused to **2038-01-19**; telemetry 0; Recall/Copilot policies set; dark mode, transparency off, legacy context menu, file extensions, Start pins policy all set; EdgeUpdate block policies set; 59 Appx deprovision keys; 47 of the 54 apps you selected for removal are already absent.
- Still present from your removal picks: only `Microsoft.XboxSpeechToTextOverlay` and `Microsoft.SecHealthUI`.
- Not yet applied: the four Application Experience scheduled tasks are still `Ready`; `edgeupdate` is Automatic (ReviOS set it to Manual); `WSAIFabricSvc` is Automatic.

**Consequence:** on this PC the tool mostly acts as a drift fixer. The big removals (Defender, AI, OneDrive, system components) were done by signed packages that the tool cannot reproduce. On a stock install, the tool's Defender "disable" would be a policy and service disable only (files stay, reversible). See question 1 at the end.

## 2. Selections I recommend you untick

| Item | Why |
|---|---|
| `sec.cpu-mitigations-off` (⛔) | Disables Spectre/Meltdown mitigations. ReviOS itself reverted it. **This PC currently has `FeatureSettingsOverride=3 / Mask=3` set, so the mitigations are already off** on this machine. I'd delete those two values as part of the tool rather than re-apply them |
| `sec.uac-off` (⚠️) | `EnableLUA=0` breaks Store apps and the Edge/WebView2 sandbox. It is currently ON (`EnableLUA=1`) and admin prompts are already off (`ConsentPromptBehaviorAdmin=0`), so you already get "no prompts" without it |
| `appx.windows-security-ui` (⛔) | Removes `Microsoft.SecHealthUI`. ReviOS only deprovisions it. It also hosts Device security and Firewall pages and Settings deep links |
| `perf.intel-tsx` | Intel-only. You have an AMD CPU, so it does nothing |
| `look.accessibility-reset` (⚠️) | Wipes the Accessibility registry keys; breaks hotkeys, high contrast, MouseKeys. Also overlaps `look.sticky-keys-prompts-off` |
| `perf.restore-point-config` (⚠️) | Strips System Restore defaults. No restore points exist today, so it gains nothing, but it removes your fallback if you ever turn it on |
| `perf.ifeo-perfoptions` (⚠️) | Puts `lsass` and `sihost` at Idle CPU priority. IFEO entries for these already exist here. On a 12-core desktop the cost is small, but this is the item ReviOS flags as able to hurt responsiveness. I'd keep only the harmless ones (SearchIndexer, ctfmon, fontdrvhost) |
| `perf.disk-cleanup-oneshot` | Deletes `SoftwareDistribution`, CBS/system logs and event logs. You lose the logs you need when an update or tweak misbehaves |
| `appx.people-experience-host` (⚠️) | Shell-integrated system app; ReviOS removes it but it isn't a user app. It is already absent here, so unticking costs nothing |

## 3. Real conflicts and overlaps among your ticks

**Security trade-off stack (not a bug, but a decision):** Defender disabled + SmartScreen off + VBS/HVCI off + Smart App Control off + **updates paused until 2038** + mitigations off. The patch level on this PC is Feb 2026, about **8 months behind** (today is Oct 2026), with no antivirus. That is the largest risk in your whole selection and the update pause is what causes the staleness.
- It also contradicts your goal of reapplying after Windows updates: with updates paused until 2038 there are none to reapply after.
- Suggestion: do not tick `upd.pause-2038` in the tool. Instead add an `update` workflow (unpause, install, run `status`, re-apply drift). Decision for you (question 2).

**Duplicates to merge** (same tweak under different ids; the engine will apply each once):
- `sec.vbs-off` + `sec.hvci-off` + `game.vbs-hvci-off`
- `svc.edgeupdate-manual` + `edge.edgeupdate-manual`
- `look.mouse-accel-off` + `game.mouse-accel-off`
- `look.menu-responsiveness` + `perf.menu-responsiveness`
- `look.startup-sound-off` + `pwr.logon-polish`
- `sec.show-file-extensions` + `shell.show-file-extensions`
- `misc.classic-photo-viewer` + `shell.photo-viewer-restore` (only needed if Photos is removed; it is, and the Photo Viewer handler is already set here)
- `svc.reviOS-service-set` already contains DiagTrack, diagnosticshub, WerSvc, PcaSvc, wisvc, WDI hosts, dam, GpuEnergyDrv, NetBT, Telemetry, tcpipreg, Wecsvc, UCPD, edgeupdate, condrv, so the 14 individual `svc.*` lines are redundant
- `priv.content-delivery-off` overlaps `appx.preinstalled-apps-block`; `start.cortana-cloud-search-off` overlaps `priv.search-cloud-history`

**Genuine semantic tensions:**
- `appx.deprovision-markers` also deprovisions **Notepad, Calculator, Paint, Windows Security**, while `start.remove-pinned-items` pins Notepad, Paint, Calculator and Store. Harmless for your current profile (the apps are installed), but **new user accounts would not get those apps**. The tool should exclude those four from the deprovision list. The current deprovision set on this PC already includes them (as ReviOS does).
- `svc.ucpd` disabled + `task.ucpd-velocity` disabled: intended pair, fine. UCPD is already off here.

## 4. Risk items I checked and consider OK for this PC

| Item | Why it's fine here |
|---|---|
| `svc.netbt` (NetBIOS off) | No SMB mappings or shares in use; already disabled |
| `svc.dam` | Desktop, no battery. Already disabled |
| `pwr.hibernate-off`, `pwr.high-performance-plan` | Desktop; already applied; no laptop heat/battery concern |
| `priv.hosts-telemetry-blocklist` | Current hosts has no custom entries. The engine should still **merge** its entries instead of replacing the file |
| `priv.location-sensors-off`, `priv.capability-consent-deny` | Desktop, Maps/Weather already removed |
| `priv.appcompat-policy` (`DisableEngine=1`) | Already set here and working; only risk is very old apps |
| `sec.smart-app-control-off` | Already Off (`VerifiedAndReputablePolicyState=0`); one-way setting, nothing to lose |
| `sec.vbs-off` / `sec.hvci-off` | Already off. Does not affect Hyper-V, WSL or Docker, which depend on the hypervisor, not on VBS |
| `edge.remove-edge` | Edge already absent; WebView2 present and the keep-WebView2 guard is ticked |
| `edge.remove-onedrive` | OneDrive isn't running, no folders redirected into OneDrive |
| `edge.remove-teams`, Phone Link, Cross Device, Photos, Dev Home | Not installed or running |
| `appx.mail-calendar`, `appx.outlook-new`, `feat.*`, `svc.remote-registry` | Nothing depends on them here (no Office/Outlook processes) |
| Spooler and Bluetooth | Not ticked, which is right: you have two label printers and 29 Bluetooth devices |

## 5. Things I could not verify

- Whether Docker/WSL actually work: `HypervisorPresent` is False although Hyper-V services are running. Needs `bcdedit /enum '{current}'` (`hypervisorlaunchtype`) in an elevated shell. This is not something your picks change, but it would explain a broken Docker.
- Defender and BitLocker status through their own cmdlets (needs admin). The registry shows `TamperProtection=4`, `PreventDeviceEncryption=1`.
- Per-item registry state for all 254 picks. Once the engine exists, `status` will report this exactly; I did not hand-check every value.

## 6. Questions that decide the rest

1. **What is the target?** (a) this already-ReviOS PC, to keep it from drifting, or (b) fresh stock Windows installs, or both? For (a) the tool is a smaller drift-fixer and Defender/AI/OneDrive stay as the CAB removals left them. For (b) it has to do the work itself and Defender will only be disabled, not removed.
2. **Updates:** keep the 2038 pause (stay at Feb 2026 patch level, no security updates), or switch to a controlled "unpause, update, re-apply" flow?
3. **Mitigations:** OK to have the tool *revert* the currently-set `FeatureSettingsOverride/Mask` so Spectre/Meltdown mitigations are back on?
