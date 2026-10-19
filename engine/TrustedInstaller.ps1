# TrustedInstaller impersonation.
# Technique: enable SeDebugPrivilege -> duplicate the SYSTEM token from winlogon.exe -> impersonate SYSTEM
# -> start the TrustedInstaller service, duplicate ITS token -> impersonate that on the current thread.
# While impersonating, .NET registry / file APIs on THIS thread run as TrustedInstaller.
# (Child processes started with Start-Process do NOT inherit a thread token; use registry/file APIs inside the block.)
# Same approach as trusted-uninstaller-cli (MIT) and revision-tool's win32_token_helper.
# NOTE: requires an elevated session. Untested outside a VM - see PLAN.md section 10.

if (-not ('WinDebloat.TI' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.ComponentModel;

namespace WinDebloat {
    public static class TI {
        [StructLayout(LayoutKind.Sequential)] struct LUID { public uint Low; public int High; }
        [StructLayout(LayoutKind.Sequential)] struct LUID_AND_ATTRIBUTES { public LUID Luid; public uint Attributes; }
        [StructLayout(LayoutKind.Sequential)] struct TOKEN_PRIVILEGES { public uint Count; public LUID_AND_ATTRIBUTES Privileges; }

        [DllImport("advapi32.dll", SetLastError = true)] static extern bool OpenProcessToken(IntPtr process, uint access, out IntPtr token);
        [DllImport("advapi32.dll", SetLastError = true)] static extern bool DuplicateTokenEx(IntPtr token, uint access, IntPtr attrs, int impersonationLevel, int tokenType, out IntPtr newToken);
        [DllImport("advapi32.dll", SetLastError = true)] static extern bool ImpersonateLoggedOnUser(IntPtr token);
        [DllImport("advapi32.dll", SetLastError = true)] static extern bool RevertToSelf();
        [DllImport("advapi32.dll", SetLastError = true)] static extern bool AdjustTokenPrivileges(IntPtr token, bool disableAll, ref TOKEN_PRIVILEGES newState, int bufLen, IntPtr prev, IntPtr retLen);
        [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)] static extern bool LookupPrivilegeValue(string system, string name, out LUID luid);
        [DllImport("kernel32.dll", SetLastError = true)] static extern IntPtr OpenProcess(uint access, bool inherit, int pid);
        [DllImport("kernel32.dll")] static extern bool CloseHandle(IntPtr h);
        [DllImport("kernel32.dll")] static extern IntPtr GetCurrentProcess();

        const uint PROCESS_QUERY_LIMITED_INFORMATION = 0x1000;
        const uint TOKEN_DUPLICATE = 0x2, TOKEN_QUERY = 0x8, TOKEN_ADJUST_PRIVILEGES = 0x20, TOKEN_ALL_ACCESS = 0xF01FF;
        const uint SE_PRIVILEGE_ENABLED = 0x2;
        const int SecurityImpersonation = 2, TokenImpersonation = 2;

        static void EnablePrivilege(string name) {
            IntPtr tok;
            if (!OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, out tok)) throw new Win32Exception(Marshal.GetLastWin32Error());
            try {
                LUID luid;
                if (!LookupPrivilegeValue(null, name, out luid)) throw new Win32Exception(Marshal.GetLastWin32Error());
                TOKEN_PRIVILEGES tp = new TOKEN_PRIVILEGES();
                tp.Count = 1; tp.Privileges.Luid = luid; tp.Privileges.Attributes = SE_PRIVILEGE_ENABLED;
                if (!AdjustTokenPrivileges(tok, false, ref tp, 0, IntPtr.Zero, IntPtr.Zero)) throw new Win32Exception(Marshal.GetLastWin32Error());
                int err = Marshal.GetLastWin32Error();
                if (err != 0) throw new Win32Exception(err, "Privilege " + name + " not held (run elevated)");
            } finally { CloseHandle(tok); }
        }

        static IntPtr DuplicateFromProcess(int pid) {
            IntPtr proc = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, false, pid);
            if (proc == IntPtr.Zero) throw new Win32Exception(Marshal.GetLastWin32Error(), "OpenProcess " + pid);
            try {
                IntPtr tok;
                if (!OpenProcessToken(proc, TOKEN_DUPLICATE | TOKEN_QUERY, out tok)) throw new Win32Exception(Marshal.GetLastWin32Error(), "OpenProcessToken " + pid);
                try {
                    IntPtr dup;
                    if (!DuplicateTokenEx(tok, TOKEN_ALL_ACCESS, IntPtr.Zero, SecurityImpersonation, TokenImpersonation, out dup)) throw new Win32Exception(Marshal.GetLastWin32Error(), "DuplicateTokenEx");
                    return dup;
                } finally { CloseHandle(tok); }
            } finally { CloseHandle(proc); }
        }

        public static void Enter(int winlogonPid, int tiPid) {
            EnablePrivilege("SeDebugPrivilege");
            IntPtr sys = DuplicateFromProcess(winlogonPid);
            try {
                if (!ImpersonateLoggedOnUser(sys)) throw new Win32Exception(Marshal.GetLastWin32Error(), "Impersonate SYSTEM");
                IntPtr ti = DuplicateFromProcess(tiPid);
                try {
                    RevertToSelf();
                    if (!ImpersonateLoggedOnUser(ti)) throw new Win32Exception(Marshal.GetLastWin32Error(), "Impersonate TrustedInstaller");
                } finally { CloseHandle(ti); }
            } finally { CloseHandle(sys); }
        }

        public static void Exit() { RevertToSelf(); }
    }
}
'@
}

function Get-TrustedInstallerPid {
    $svc = Get-Service -Name TrustedInstaller -ErrorAction Stop
    if ($svc.Status -ne 'Running') {
        Start-Service -Name TrustedInstaller -ErrorAction Stop
        $deadline = (Get-Date).AddSeconds(15)
        while ((Get-Date) -lt $deadline) {
            $svc.Refresh()
            if ($svc.Status -eq 'Running') { break }
            Start-Sleep -Milliseconds 300
        }
    }
    $p = Get-CimInstance Win32_Service -Filter "Name='TrustedInstaller'"
    if (-not $p -or -not $p.ProcessId) { throw 'TrustedInstaller service has no process id' }
    return [int]$p.ProcessId
}

function Invoke-AsTrustedInstaller {
    <# Runs a scriptblock on the current thread while impersonating TrustedInstaller. #>
    param([Parameter(Mandatory)][scriptblock]$ScriptBlock)
    if (-not (Test-IsAdmin)) { throw 'TrustedInstaller operations require an elevated session.' }
    $winlogon = (Get-Process -Name winlogon -ErrorAction Stop | Select-Object -First 1).Id
    $tiPid = Get-TrustedInstallerPid
    [WinDebloat.TI]::Enter($winlogon, $tiPid)
    try {
        return (& $ScriptBlock)
    }
    finally {
        [WinDebloat.TI]::Exit()
    }
}
