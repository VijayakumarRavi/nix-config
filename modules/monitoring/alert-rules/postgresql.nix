{
  groups = [
    {
      name = "postgresql-alerts";
      rules = [
        {
          alert = "PostgresDown";
          expr = "pg_up == 0";
          for = "1m";
          labels.severity = "critical";
          annotations = {
            summary = "PostgreSQL down on {{ $labels.instance }}";
            description = "PostgreSQL instance {{ $labels.instance }} is unreachable or down. Exporter is unable to scrape database metrics.";
            remediation = "SSH into the host and run `systemctl status postgresql` to check service state. Inspect system logs and database log outputs.";
          };
        }
        {
          alert = "PostgresHighConnections";
          expr = "pg_stat_database_numbackends > 80";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "PostgreSQL high connection count on {{ $labels.instance }}";
            description = "Active connection count is {{ $value }} on database host {{ $labels.instance }}. Over 80% of max limit.";
            remediation = "Verify client applications are pooling connections. Investigate running transactions using `select * from pg_stat_activity`.";
          };
        }
        {
          alert = "PostgresCriticalConnections";
          expr = "pg_stat_database_numbackends > 95";
          for = "2m";
          labels.severity = "critical";
          annotations = {
            summary = "PostgreSQL critical connection count on {{ $labels.instance }}";
            description = "Active connections reached {{ $value }}, close to max pool size. Database may refuse new client connections.";
            remediation = "Urgent. Kill idle connections or increase max_connections in configuration. Identify if there's a connection leak.";
          };
        }
        {
          alert = "PostgresDeadlocks";
          expr = "rate(pg_stat_database_deadlocks[5m]) > 0";
          for = "0m";
          labels.severity = "warning";
          annotations = {
            summary = "PostgreSQL deadlocks detected: {{ $labels.datname }}";
            description = "Database {{ $labels.datname }} on {{ $labels.instance }} is experiencing deadlocks at rate {{ printf \"%.4f\" $value }}/s.";
            remediation = "Examine application query logic. Deadlocks indicate concurrent transactions trying to lock the same resources in different orders.";
          };
        }
        {
          alert = "PostgresLongTransaction";
          expr = "pg_stat_activity_max_tx_duration{state=\"active\"} > 300";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "PostgreSQL long-running transaction: {{ $labels.instance }}";
            description = "Active transaction has been running for over 5 minutes ({{ printf \"%.2f\" $value }}s) on {{ $labels.instance }}.";
            remediation = "Examine locks and query plans. Run `SELECT * FROM pg_stat_activity WHERE state = 'active' ORDER BY xact_start ASC;` and kill the query if necessary.";
          };
        }
      ];
    }
  ];
}
