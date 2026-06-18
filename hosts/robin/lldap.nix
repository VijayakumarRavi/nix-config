# LLDAP - Lightweight Directory Access Protocol server
# Connects to PostgreSQL via Unix socket using peer authentication
{
  config,
  pkgs,
  ...
}: let
  format = pkgs.formats.toml {};
in {
  # ── Sops secrets: environment file and admin password ─────────────────
  # Add to secrets.yaml (sops secrets.yaml):
  #   lldap_admin_password: your-admin-password
  #   lldap_env: |
  #     LLDAP_JWT_SECRET=your-jwt-secret
  #     LLDAP_KEY_SEED=your-seed-key
  #     LLDAP_SMTP_OPTIONS__ENABLE_PASSWORD_RESET=true
  #     LLDAP_SMTP_OPTIONS__FROM=auth@vjlab.dev
  #     LLDAP_SMTP_OPTIONS__USER=your-smtp-user
  #     LLDAP_SMTP_OPTIONS__PASSWORD=your-smtp-password
  #     LLDAP_SMTP_OPTIONS__SERVER=your-smtp-server
  #     LLDAP_SMTP_OPTIONS__PORT=465
  #     LLDAP_SMTP_OPTIONS__SMTP_ENCRYPTION=TLS
  sops.secrets.lldap_env = {};
  sops.secrets.lldap_admin_password = {};

  services.lldap = {
    enable = true;

    database.createLocally = false;
    database.type = "postgresql";

    environmentFile = config.sops.secrets.lldap_env.path;

    # Silence the warning that force_ldap_user_pass_reset is false
    silenceForceUserPassResetWarning = true;

    settings = {
      ldap_user_pass_file = "/run/credentials/lldap.service/lldap_admin_password";
      database_url = "postgresql:///lldap?host=/run/postgresql&port=${toString config.services.postgresql.settings.port}";
      ldap_host = "0.0.0.0";
      http_host = "0.0.0.0";
      ldap_port = 3890;
      http_port = 17170;
      http_url = "https://lldap.vjlab.dev";
      ldap_base_dn = "dc=vjlab,dc=dev";
      ldap_user_dn = "admin";
      ldap_user_email = "admin@vjlab.dev";

      # Enable LDAPS directly on LLDAP
      ldaps_options = {
        enabled = true;
        port = 32621;
        cert_file = "/var/lib/acme/vjlab.dev/fullchain.pem";
        key_file = "/var/lib/acme/vjlab.dev/key.pem";
      };
    };
  };

  systemd.services.lldap = {
    after = [
      "postgresql.service"
      "postgresql-setup.service"
      "acme-vjlab.dev.service"
    ];
    wants = [
      "postgresql.service"
      "acme-vjlab.dev.service"
    ];
    requires = ["postgresql-setup.service"];

    serviceConfig = {
      LoadCredential = [
        "lldap_admin_password:${config.sops.secrets.lldap_admin_password.path}"
      ];
      SupplementaryGroups = ["nginx"];
    };

    # Block service active status until the healthcheck command reports LLDAP is healthy
    serviceConfig.ExecStartPost = pkgs.writeShellScript "lldap-healthcheck" ''
      echo "Waiting for LLDAP to be healthy..."
      for i in {1..30}; do
        if ${config.services.lldap.package}/bin/lldap healthcheck --config-file ${format.generate "lldap_config.toml" config.services.lldap.settings}; then
          echo "LLDAP is healthy!"
          exit 0
        fi
        sleep 1
      done
      echo "LLDAP healthcheck failed!"
      exit 1
    '';
  };

  # ── Nginx virtual host for administration interface ─────────────────────
  services.nginx = {
    virtualHosts."lldap.vjlab.dev" = {
      useACMEHost = "vjlab.dev";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:17170";
      };
    };
  };

  # Open LDAPS port
  networking.firewall.allowedTCPPorts = [32621];

  # Enforce 0700 mode on `/var/lib/private` during activation
  system.activationScripts.lldapPrivateDirPerms = {
    text = ''
      if [ -d /var/lib/private ]; then
        chmod 0700 /var/lib/private
      fi
    '';
    deps = [];
  };
}
