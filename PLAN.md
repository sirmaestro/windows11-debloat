# Implementation Plan — Windows 11 Debloat CLI

Personal-use, CLI-only, standalone debloat/optimize/tweak tool for **Windows 11 24H2 and later**, run on an existing install (no ISO building). Settings preferences come from the ReviOS playbook; engine design is our own.

Status (2026-10-17): **M0-M3 implemented, M4-M7 code written but untested outside unit tests.** See "Implementation status" at the end. The tweak pick-list is [TWEAKS.md](TWEAKS.md) (user ticks what to include); usage is in [README.md](README.md).

Decisions added after the first draft:
- **Target:** fresh stock Windows 11 installs (not this PC, which already runs ReviOS), but it must also work after the user updates Windows manually and wants settings re-applied (`status` / `apply -DriftOnly` / `schedule`).
- **Updates:** manual. Windows Update is paused to 2038 by a tweak; `updates resume` -> update -> `apply -DriftOnly` -> `updates pause`.
- **Defender:** the user does not care about it; kept as a separate opt-in profile (`defender`) that never blocks the rest.
- **Spectre/Meltdown mitigations:** left at Windows defaults (`sec.cpu-mitigations-off` not selected).
- **Tests:** a dependency-free runner (`tests/Invoke-Tests.ps1`) instead of Pester (the machine only has Pester 3.4).

## 1. Goals / non-goals

**Goals**
- One CLI (`debloat.ps1`) that applies a chosen set of tweaks idempotently.
- Every change is reversible (previous value snapshotted) and previewable (`plan`).
- Detects drift after Windows updates and re-applies only what was undone.
- Edge removal and Defender disable included (as separate, opt-in profiles).
- No third-party runtime dependencies (no AME Wizard, no `revitool.exe`, no downloaded CABs).

**Non-goals**
- GUI, ISO/WIM customization, app installer (WinGet) — out of scope.
- WinSxS/CBS package removal (Revision's signed `.cab` packages cannot be reproduced; see §7).
- Supporting Windows 10 or Windows 11 before 24H2 (build < 26100).

## 2. Decisions made so far

| Topic | Decision |
|---|---|
| Base | Own engine; references are used as *data and technique sources* only |
| Language | Windows PowerShell 5.1-compatible (ships with 24H2; no install). Run from `powershell.exe`; also works in pwsh 7 |
| Catalog format | `.psd1` data files (native to PS 5.1, supports comments; 5.1 has no YAML parser) |
| Target | Build ≥ 26100 (24H2, 25H2, 26H1+). Region: New Zealand (non-EEA) — Edge uninstall technique depends on this |
| Defender | Reimplement Revision's *registry/service/policy* disable; skip the CAB package. Reversible. Tamper Protection must be turned off manually first |
| Edge | Port the `EDGE.ps1` technique; keep WebView2 |
| Browser | None installed by the tool |
| Testing | Hyper-V VM with checkpoints before touching the real machine |
| Licensing | Personal use. Reuse winutil (MIT) / trusted-uninstaller-cli (MIT) code freely; for GPL (optimizerDuck, revision-tool), CC BY-SA (playbook) and PolyForm (Winhance) sources, use them as *references* and write our own implementation + attribute in the catalog's `src` field |

## 3. Repository layout (planned)

```
debloat.ps1                 CLI entry point: list | plan | apply | status | revert | schedule
engine/
  Context.ps1               build/region/edition checks, logging, elevation check
  Snapshot.ps1              read/store/restore prior state (JSON)
  Actions/
    Registry.ps1            value/key set+delete, hive handling (HKLM, HKCU, default user, per-user)
    Service.ps1             start type, stop
    Appx.ps1                Remove-AppxPackage -AllUsers + deprovision
    Capability.ps1          Windows capabilities / optional features (DISM cmdlets)
    ScheduledTask.ps1       disable / delete tasks
    File.ps1                delete/create files
    Exec.ps1                run command, with test/revert hooks
  TrustedInstaller.ps1      token impersonation helper (C# via Add-Type; technique from trusted-uninstaller-cli, MIT)
catalog/
  *.psd1                    one file per category; each tweak = id, name, risk, builds, actions[]
profiles/
  safe.psd1                 list of tweak ids (+ options)
  edge.psd1
  defender.psd1
tests/                      Pester tests (catalog schema, action test/apply/revert on a throwaway key)
docs/                       generated tweak list, usage
```

## 4. Catalog schema (per tweak)

```powershell
@{
  Id      = 'privacy.disable-telemetry'
  Name    = 'Disable telemetry'
  Risk    = 'low'                      # low | med | high
  Builds  = @{ Min = 26100 }
  Scope   = 'machine'                  # machine | user
  Source  = 'playbook:privacy/telemetry.yml'
  Actions = @(
    @{ Type='Registry'; Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowTelemetry'; Kind='DWord'; Value=0 }
  )
  # Optional: Requires = @('tamper-protection-off'); RebootRequired = $true; RestartExplorer = $true
}
```

Every action type implements three operations:
- `Test`   — is the desired state already present? (drives `status`, `plan`, `--drift-only`)
- `Apply`  — make the change (after `Snapshot` captured the previous state)
- `Revert` — restore the snapshotted state (or documented default if the value did not exist)

## 5. CLI behaviour

| Command | Behaviour |
|---|---|
| `list [--category X] [--profile P]` | Show tweaks, current state (applied / not applied / n/a for this build) |
| `plan --profile P` | Dry run: what would change, with old → new values. Never writes |
| `apply --profile P [--only id,id] [--yes]` | Snapshot, apply, report. Creates a restore point first (optional flag) |
| `status [--profile P]` | Drift report: which applied tweaks were undone |
| `revert [--run <id> \| --only id,id]` | Restore from snapshots |
| `schedule [--remove]` | Register a startup/logon scheduled task running `apply --drift-only` |

Exit codes: 0 ok, 1 partial failure, 2 precondition failed (not admin, wrong build, Tamper Protection on).

## 6. Cross-cutting design points

1. **Per-user vs machine scope.** Dark mode, legacy context menu, transparency etc. live in HKCU. When elevated we must write to the *interactive user's* hive (load `NTUSER.DAT` or resolve their SID) and to the Default user hive so new accounts inherit them.
2. **Snapshots.** `C:\ProgramData\<tool>\snapshots\<timestamp>.json`: for each action, previous value (or "absent"). `revert` replays in reverse order.
3. **TrustedInstaller.** Needed for some protected keys (Defender), file removal, and some services. Implement token impersonation via the TrustedInstaller service (technique visible in `trusted-uninstaller-cli/Core/Win32` and `revision-tool/lib/core/trusted_installer`).
4. **Ordering.** Follow ReviOS constraints (documented in `playbook/docs` and `main.yml` comments): Edge/OneDrive/Teams removal before WinSxS-style changes; kill Explorer only after Defender changes; Appx removal before shell restart.
5. **Windows Update resilience.** Prefer *policy* keys over direct settings where both exist; `status` detects reverts; Edge/Appx reprovisioning and the Defender policy key (removed by `gpupdate` after Jan-2026 updates, per Revision's source comment) are expected drift cases.
6. **Safety gates.** Refuse to run if: not elevated, build < 26100, pending reboot (warn), Tamper Protection on when `defender` profile selected. `--force` to override warnings only.

## 7. Defender and Edge (the fragile parts)

### Defender — "disable", not "remove"
Revision's `disableDefender` does: policy keys (`DisableAntiSpyware`, `DisableAntiVirus`, `DisableRealtimeMonitoring`) → `gpupdate` → TrustedInstaller writes to `HKLM\SOFTWARE\Microsoft\Windows Defender` (`DisableAntiSpyware`, `DisableAntiVirus`) → policies again (workaround for Jan-2026 updates) → `MDCoreSvc` start=4 → **install signed CAB that removes components**. We reimplement everything except the CAB:
- The CAB is a signed CBS servicing package that Revision builds; installing one requires a specific signing EKU, so we cannot produce our own.
- Without it the Defender files remain on disk; services/policies are disabled and reversible.
- To verify in VM: which service start values are writable (as TrustedInstaller) with Tamper Protection off on 24H2/25H2.

### Edge — uninstall technique
Port `playbook/src/Executables/EDGE.ps1`: remove `NoRemove`, set `EdgeUpdateDev\AllowUninstall`, create a stub `SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\MicrosoftEdge.exe`, run Edge's `setup.exe --uninstall --force-uninstall` with a spoofed allowed parent process (`sihost.exe` copy of cmd.exe in `ImmersiveControlPanel`), clean shortcuts; uninstall Edge Update. Requires non-EEA region (NZ ✓). Add policies to block reinstall (`EdgeUpdate` `InstallDefault=0`, etc.). **Keep WebView2.** Cross-check against `Registry-Tweaks-Scripts/Remove-Edge-ISO.ps1`.

## 8. Milestones

| # | Milestone | Done when |
|---|---|---|
| M0 | Scaffold repo layout + schema validation (Pester) | `Invoke-Pester` validates all catalog files |
| M1 | Engine core: Context, Snapshot, Registry action (machine+user), `plan/apply/revert/status` | Round-trip one tweak in VM: apply → status ok → revert → state restored |
| M2 | Remaining actions: Service, Appx, Capability, ScheduledTask, File, Exec | Each has Pester test for Test/Apply/Revert |
| M3 | **Safe profile** (§9) ported from the user's picks in TWEAKS.md | `plan` matches picks; `apply` + `revert` clean on VM 24H2 |
| M4 | TrustedInstaller helper | Can write a TI-protected key and revert it |
| M5 | Edge profile | Edge gone on VM (NZ region), WebView2 intact, `status` detects reinstall |
| M6 | Defender disable profile | Defender off after reboot on VM, survives a cumulative update test; revert re-enables |
| M7 | `schedule` + drift re-apply | After simulated drift, startup task restores only drifted tweaks |
| M8 | Docs + generated tweak list | README, usage, TWEAKS list generated from catalog |

## 9. Safe profile (initial scope — pending user picks)

Baseline taken from the user's previous ReviOS selections:
- Disable Defender *(profile `defender`, separate)*, disable hibernate
- Remove Edge *(profile `edge`)*, OneDrive, AI (Copilot + Recall), Teams, Photos, Dev Home, Your Phone
- Dark mode, legacy context menu, disable transparency effects, remove pinned Start items
- No browser installed; Xbox apps, wallpaper, automatic-maintenance: not selected

Everything else in the profile comes from the user's choices in [TWEAKS.md](TWEAKS.md).

## 10. Open items / to verify in the VM

- Does `ConfigureStartPins` policy take effect on Windows 11 Pro 24H2? (Revision writes it under `PolicyManager\current\device\Start`.)
- Which Defender service start values are writable with Tamper Protection off, and does the disable survive Defender platform updates?
- Recall as optional feature: present on non-Copilot+ hardware? (Needs `Get-WindowsOptionalFeature -Online -FeatureName Recall`.)
- Default-user-hive handling for per-user tweaks.
- Whether `powercfg /h off` interacts with anything else in the chosen profile.

## 11. Source map (where each piece comes from)

| Area | Primary reference |
|---|---|
| Tweak breadth + presets | `winutil/config/*.json` (MIT) |
| ReviOS-preferred settings & ordering | `playbook/src/Configuration/**`, `playbook/docs` |
| Edge removal | `playbook/src/Executables/EDGE.ps1`, `Registry-Tweaks-Scripts/Remove-Edge-ISO.ps1` |
| Defender disable | `revision-tool/src/lib/features/tweaks/security/security_service.dart` |
| TrustedInstaller | `trusted-uninstaller-cli/Core/Win32`, `revision-tool/src/lib/core/trusted_installer` |
| Revert / history design | `optimizerDuck/optimizerDuck/Services/Revert`, `Domain/Revert/Steps` |
| Setting definitions / re-apply idea | `Winhance/src/Winhance.Core/Features/**` |
| Services list | `Registry-Tweaks-Scripts/services.json` |

## Implementation status (2026-10-17)

| # | Milestone | State |
|---|---|---|
| M0 | Scaffold, schema validation | Done: `validate`, `Test-ActionDefinition`, 242 tweaks load and validate |
| M1 | Engine core: Context, Snapshot, Registry (machine + every user + Default template), plan/apply/revert/status | Done and unit-tested (46 checks incl. full apply -> drift -> `-DriftOnly` -> revert pipeline with a faked admin check) |
| M2 | Service, Appx, Capability, Feature, ScheduledTask, File, Hosts, Env, Bcdedit, Exec, Script actions | Code complete; only Registry/Exec/Service-N/A paths are exercised by tests. Others need an elevated VM run |
| M3 | Selected tweaks as catalog entries + profiles | Done: 242 tweaks (user's 246 ticks minus 4 deferred), profiles `all/base/edge/defender/updates` |
| M4 | TrustedInstaller helper | Written (C# via Add-Type compiles); **never executed elevated** |
| M5 | Edge removal | Script written (port of EDGE.ps1); not run |
| M6 | Defender disable | Script written (revision-tool flow without the CAB); not run |
| M7 | `schedule` + drift re-apply | Written; not run |
| M8 | Docs | README, this plan, selection review |

### Deferred / not implemented (ticked or discussed, but left out on purpose)
- `edge.protocol-redirect`: needs the `ie_to_edge_stub.exe` helper from Winhance (not in references).
- `perf.explorer-downloads-no-groupby`, `perf.ngen-powershell`: mechanism not specified well enough to implement safely.
- Revision's signed CBS packages (Defender/AI/OneDrive/system components removal): not reproducible.
- ReviOS `DefaultLayouts.xml` for Start: purpose unverified, skipped.

### Next steps
1. Create a Hyper-V VM (Windows 11 Pro 24H2, region New Zealand), checkpoint, run `plan -Profile all`, then `apply -Profile base` and compare with `plan` again.
2. Verify the unverified items (section 10) and fix what the VM shows: TI impersonation, Defender keys with Tamper Protection off, `ConfigureStartPins` on Pro, Edge removal, feature/capability names on 24H2.
3. Run an actual cumulative update in the VM and confirm `status` reports the drift and `apply -DriftOnly` repairs it.
