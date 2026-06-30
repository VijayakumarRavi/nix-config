{
  groups = [
    {
      name = "node-alerts";
      rules = [
        {
          alert = "NodeDown";
          expr = "up{job=\"node\"} == 0";
          for = "2m";
          labels.severity = "critical";
          annotations = {
            summary = "Node down: {{ $labels.instance }}";
            description = "The node-exporter target {{ $labels.instance }} has been offline/down for more than 2 minutes.";
            remediation = "Check host power state, virtual machine status on Zoro/Robin, network routing, or systemd services for node-exporter.";
          };
        }
        {
          alert = "NodeHighCPU";
          expr = "100 - (avg by(instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > 80";
          for = "15m";
          labels.severity = "warning";
          annotations = {
            summary = "High CPU load: {{ $labels.instance }}";
            description = "CPU usage is above 80% on {{ $labels.instance }} for the last 15 minutes.";
            remediation = "Run `top` or `htop` on the target host to identify CPU-intensive processes.";
          };
        }
        {
          alert = "NodeCriticalCPU";
          expr = "100 - (avg by(instance) (rate(node_cpu_seconds_total{mode=\"idle\"}[5m])) * 100) > 95";
          for = "5m";
          labels.severity = "critical";
          annotations = {
            summary = "Critical CPU load: {{ $labels.instance }}";
            description = "CPU usage is above 95% on {{ $labels.instance }} for the last 5 minutes.";
            remediation = "Investigate immediately. Identify and kill rogue processes or scale resources.";
          };
        }
        {
          alert = "NodeHighMemory";
          expr = "node_memory_Active_bytes / node_memory_MemTotal_bytes * 100 > 80";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "High memory usage: {{ $labels.instance }}";
            description = "Memory usage is above 80% on {{ $labels.instance }}. Only {{ printf \"%.2f\" $value }}% active memory remaining.";
            remediation = "Check memory consumption using `free -m` and look for leaks or processes consuming large amounts of RAM.";
          };
        }
        {
          alert = "NodeCriticalMemory";
          expr = "node_memory_Active_bytes / node_memory_MemTotal_bytes * 100 > 95";
          for = "2m";
          labels.severity = "critical";
          annotations = {
            summary = "Critical memory usage: {{ $labels.instance }}";
            description = "Memory usage is above 95% on {{ $labels.instance }}. High risk of Out Of Memory (OOM) killer terminating processes.";
            remediation = "Act immediately. Stop non-essential services, check `dmesg` for OOM messages, and restart memory-heavy processes.";
          };
        }
        {
          alert = "NodeDiskWarning";
          expr = "(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100 > 80";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "Low disk space: {{ $labels.instance }} ({{ $labels.mountpoint }})";
            description = "Disk usage is above 80% on {{ $labels.instance }} on mount point {{ $labels.mountpoint }}. Current usage is {{ printf \"%.2f\" $value }}%.";
            remediation = "Check disk usage with `df -h`. Clean up temporary files, unused docker images/containers, log files, or rotate journals.";
          };
        }
        {
          alert = "NodeDiskCritical";
          expr = "(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100 > 90";
          for = "2m";
          labels.severity = "critical";
          annotations = {
            summary = "Critical disk space: {{ $labels.instance }} ({{ $labels.mountpoint }})";
            description = "Disk usage is above 90% on {{ $labels.instance }} on mount point {{ $labels.mountpoint }}. Current usage is {{ printf \"%.2f\" $value }}%. Only small buffer remains.";
            remediation = "Urgent cleanup required. Clean journald logs using `journalctl --vacuum-size=100M`, clean nix store using `nix-store --gc`, or free space manually.";
          };
        }
        {
          alert = "NodeSwapUsage";
          expr = "(node_memory_SwapTotal_bytes - node_memory_SwapFree_bytes) / node_memory_SwapTotal_bytes * 100 > 50";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "High swap usage: {{ $labels.instance }}";
            description = "Swap usage is above 50% on {{ $labels.instance }}. Current swap usage is {{ printf \"%.2f\" $value }}%.";
            remediation = "Check system memory state. Consider increasing memory or adjusting swappiness if CPU is thrashing.";
          };
        }
        {
          alert = "NodeOOMKill";
          expr = "increase(node_vmstat_oom_kill[5m]) > 0";
          for = "0m";
          labels.severity = "critical";
          annotations = {
            summary = "OOM kill detected: {{ $labels.instance }}";
            description = "System has killed a process due to Out Of Memory (OOM) on {{ $labels.instance }}.";
            remediation = "Run `dmesg -T | grep -i oom` on the host to see which service was killed and examine its resource limits.";
          };
        }
        {
          alert = "NodeDiskReadOnly";
          expr = "node_filesystem_readonly == 1";
          for = "0m";
          labels.severity = "critical";
          annotations = {
            summary = "Filesystem read-only: {{ $labels.instance }} ({{ $labels.mountpoint }})";
            description = "Filesystem {{ $labels.mountpoint }} has flipped to read-only on {{ $labels.instance }} due to underlying filesystem corruption or storage errors.";
            remediation = "Investigate disk health immediately via `dmesg` or smartctl. A reboot or fsck may be required.";
          };
        }
      ];
    }
  ];
}
