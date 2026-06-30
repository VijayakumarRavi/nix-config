{
  groups = [
    {
      name = "systemd-alerts";
      rules = [
        {
          alert = "SystemdUnitFailed";
          expr = "node_systemd_unit_state{state=\"failed\"} == 1";
          for = "1m";
          labels.severity = "critical";
          annotations = {
            summary = "Systemd unit failed: {{ $labels.name }} on {{ $labels.instance }}";
            description = "The systemd service/unit {{ $labels.name }} has failed on {{ $labels.instance }}.";
            remediation = "SSH into the host and run `systemctl status {{ $labels.name }}` and `journalctl -u {{ $labels.name }}` to diagnose the failure.";
          };
        }
        {
          alert = "SystemdTimerMissed";
          # node_systemd_timer_last_trigger_seconds can tell us when a timer last triggered.
          # If a timer missed its scheduled run, it's captured here.
          expr = "node_systemd_timer_last_trigger_seconds == 0";
          for = "15m";
          labels.severity = "warning";
          annotations = {
            summary = "Systemd timer missed run: {{ $labels.name }} on {{ $labels.instance }}";
            description = "The systemd timer {{ $labels.name }} has not triggered yet or missed its execution window.";
            remediation = "Check the timer status via `systemctl list-timers` and verify that the target service can run manually.";
          };
        }
      ];
    }
  ];
}
