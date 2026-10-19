# windows11-debloat

Personal CLI to debloat and tune Windows 11 (24H2 and later). Declarative catalog of tweaks, dry-run planning, snapshots with revert, and drift detection so settings can be re-applied after Windows updates. No GUI, no installer, no third-party runtime: Windows PowerShell 5.1 (ships with Windows).

Status: **engine and catalog implemented and unit-tested; not yet run elevated on a real or virtual machine.** Try it in a VM with a checkpoint first (see "Testing" below).

## Usage

Run from an elevated PowerShell (`plan`, `list`, `validate`, `status` also work unelevated, with reduced accuracy):

```powershell
.\debloat.ps1 validate                      # catalog + profiles consistent?
.\debloat.ps1 list -Profile base            # what is in a profile
.\debloat.ps1 plan -Profile base -Detail    # dry run: old -> new values, never writes
.\debloat.ps1 apply -Profile base           # snapshots first; asks you to type YES
.\debloat.ps1 status -Profile all           # which applied tweaks did Windows undo (drift)?
.\debloat.ps1 apply -DriftOnly              # re-apply only what drifted
.\debloat.ps1 revert -Only 'priv.*'         # restore the state from before the tool changed it
.\debloat.ps1 revert -Run last              # undo the most recent run
.\debloat.ps1 schedule -Profile all         # re-apply drift at startup/logon (SYSTEM task)
.\debloat.ps1 updates resume|pause|status   # Windows Update pause to 2038-01-19
```

`-Only` takes comma-separated ids with wildcards (`'priv.*,svc.diagtrack'`), `-Category` takes id prefixes (`priv`, `svc`, `appx` ...).

### Profiles (generated from the `[x]` ticks in TWEAKS.md by `tools\New-Profiles.ps1`)

| Profile | Contents |
|---|---|
| `base` | everything ticked except Edge, Defender and the update pause |
| `edge` | Edge removal + reinstall protection (non-EEA region required) |
| `defender` | Defender disable (turn Tamper Protection off first) |
| `updates` | Windows Update pause etc. |
| `all` | all of the above, ordered by phase |

Suggested order on a fresh install: fully update Windows -> install a browser (Edge is removed) -> `apply -Profile base` -> `edge` -> turn Tamper Protection off -> `defender` -> reboot -> `updates`.
Update cycle later: `updates resume` -> run Windows Update -> `apply -DriftOnly` -> `updates pause`.

## Layout

```
debloat.ps1             CLI
engine/                 Common, Hives (per-user + Default-user HKCU expansion), TrustedInstaller, Catalog, Snapshot, Commands
engine/Actions/         Registry, Service, Appx/Capability/Feature, ScheduledTask/File/Hosts/Env/Bcdedit, Exec/Script
engine/scripts/         complex tweaks (Edge, OneDrive, Defender, Start pins, update pause, power plan ...)
catalog/*.psd1          the tweaks (data only)
profiles/*.psd1         generated id lists
tests/Invoke-Tests.ps1  self-tests (no Pester, no elevation; throwaway HKCU key)
tools/New-Profiles.ps1  regenerate profiles from TWEAKS.md
TWEAKS.md               the pick-list: tick [x] what you want, then run tools\New-Profiles.ps1
docs/                   plan, selection review, per-tweak mechanism notes (docs/tweaks/*.mech.md), raw inventories
references/            the upstream projects this was derived from (read-only)
```

State and logs live in `C:\ProgramData\WinDebloat\` (`runs\` snapshots, `state.json`, `logs\`).

## Testing

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests\Invoke-Tests.ps1
```
Covers: catalog loading/validation, registry set/delete/undo incl. DWORD/Binary/MultiString, drift detection, snapshot JSON round trip, and the full apply -> status -> drift -> `-DriftOnly` -> revert pipeline against a throwaway HKCU key (admin is faked inside the test and state goes to a temp directory).

**Not covered by automated tests** (needs an elevated VM run): TrustedInstaller impersonation, Appx/capability/feature removal, services, scheduled tasks, Edge/OneDrive/Defender scripts, Start pin policy on Pro 24H2.

## Safety notes

- High-risk items (Defender, Edge, VBS/HVCI) ask for explicit confirmation and are listed before apply.
- Appx, Edge and OneDrive removals are **not reversible by the tool** (reinstall via winget/Store).
- Defender "disable" is policy + service based; it does not remove files like Revision's signed packages.
- `sec.refresh-root-certs` imports Microsoft root certificates into the machine Root store and is not undone by `revert`.
