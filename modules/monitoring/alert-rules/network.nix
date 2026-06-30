{
  groups = [
    {
      name = "network-alerts";
      rules = [
        {
          alert = "NetworkInterfaceErrors";
          expr = "rate(node_network_receive_errors_total[5m]) > 0 or rate(node_network_transmit_errors_total[5m]) > 0";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "Network interface errors detected on {{ $labels.instance }}";
            description = "Network interface {{ $labels.device }} is experiencing packet receive/transmit errors on host {{ $labels.instance }}.";
            remediation = "Check host network interfaces using `ip -s link show {{ $labels.device }}`. Inspect kernel logs using `dmesg | grep -E 'eth0|enp'` for driver errors.";
          };
        }
      ];
    }
  ];
}
