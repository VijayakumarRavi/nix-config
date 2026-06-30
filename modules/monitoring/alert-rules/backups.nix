{
  groups = [
    {
      name = "backup-alerts";
      rules = [
        # pgBackRest Alerts
        {
          alert = "PgBackrestBackupTooOld";
          expr = "min by (instance, job, host, stanza) (pgbackrest_backup_since_last_completion_seconds{backup_type=~\"diff|full\"}) > 26 * 3600";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "pgBackRest backup too old on {{ $labels.instance }}";
            description = "No pgBackRest full or differential backup has completed in the last 26 hours. Current age: {{ printf \"%.2f\" $value }} seconds.";
            remediation = "Check the pgBackRest backup timer status with `systemctl status pgbackrest-backup.timer` on Robin and look at the logs of `pgbackrest-backup.service`.";
          };
        }
        {
          alert = "PgBackrestBackupCritical";
          expr = "min by (instance, job, host, stanza) (pgbackrest_backup_since_last_completion_seconds{backup_type=~\"diff|full\"}) > 48 * 3600";
          for = "5m";
          labels.severity = "critical";
          annotations = {
            summary = "pgBackRest backup critically old on {{ $labels.instance }}";
            description = "No pgBackRest full or differential backup has completed in the last 48 hours. Backup coverage is missing.";
            remediation = "Urgent. Check pgBackRest service, configuration, S3 network connectivity, and AWS/Cloudflare storage quota.";
          };
        }
        {
          alert = "PgBackrestFullTooOld";
          expr = "pgbackrest_backup_since_last_completion_seconds{backup_type=\"full\"} > 8 * 24 * 3600";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "pgBackRest full backup too old on {{ $labels.instance }}";
            description = "No pgBackRest full backup has completed in the last 8 days. Stale reference backup.";
            remediation = "Force trigger a full pgBackRest backup or check the weekly full backup systemd timer configuration.";
          };
        }
        {
          alert = "PgBackrestArchiveFailing";
          expr = "pgbackrest_wal_archive_status == 0";
          for = "5m";
          labels.severity = "critical";
          annotations = {
            summary = "pgBackRest WAL archiving failing on {{ $labels.instance }}";
            description = "The pgBackRest WAL archiver has failed to push WAL segments to S3. WAL archive status is currently unhealthy.";
            remediation = "Check PostgreSQL logs and pgbackrest logs on Robin. Verify disk space, S3 access, and `archive_command` configuration.";
          };
        }

        # Restic Alerts
        {
          alert = "ResticBackupTooOld";
          # time() gives current unix timestamp, restic_backup_timestamp is the timestamp of the last backup
          expr = "time() - restic_backup_timestamp > 3 * 3600";
          for = "5m";
          labels.severity = "warning";
          annotations = {
            summary = "Restic backup too old for {{ $labels.client_hostname }}";
            description = "The last restic backup snapshot for client {{ $labels.client_hostname }} (paths: {{ $labels.snapshot_paths }}) is older than 3 hours.";
            remediation = "Check systemd status of restic backup services on Robin/Zoro. Verify backend repository reachability and credentials.";
          };
        }
        {
          alert = "ResticBackupCritical";
          expr = "time() - restic_backup_timestamp > 6 * 3600";
          for = "5m";
          labels.severity = "critical";
          annotations = {
            summary = "Restic backup critically old for {{ $labels.client_hostname }}";
            description = "The last restic backup snapshot for client {{ $labels.client_hostname }} is older than 6 hours. High risk of data loss.";
            remediation = "Urgent. Check why the restic backup systemd service is failing. Run manual restic backup to diagnose the issue.";
          };
        }
      ];
    }
  ];
}
