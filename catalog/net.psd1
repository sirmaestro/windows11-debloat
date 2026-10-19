# Network tweaks (group 1).
@{
    Tweaks = @(
        @{
            Id = 'net.ipv4-preferred'
            Name = 'Prefer IPv4 over IPv6 (Tcpip6 DisabledComponents=32)'
            Risk = 'low'
            Phase = 10
            Source = 'WU'
            Note = 'Same value name as net.teredo-disable and net.ipv6-disable: last writer wins.'
            Reboot = $true
            Actions = @(
                @{ Type = 'Registry'; Path = 'HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'; Name = 'DisabledComponents'; Kind = 'DWord'; Value = 32 }
            )
        }
    )
}
