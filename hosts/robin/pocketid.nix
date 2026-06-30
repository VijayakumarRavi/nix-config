# Pocket ID — OIDC identity provider with LDAP backend
# Connects to local PostgreSQL via Unix socket (peer auth)
# Secrets loaded from sops-nix environment file
{
  config,
  pkgs,
  ...
}: {
  # ── Sops secret: environment file with SMTP/LDAP credentials ──────────
  # Add to secrets.yaml (sops secrets.yaml):
  #   pocketid_env: |
  #     SMTP_HOST=smtp.example.com
  #     SMTP_PORT=587
  #     SMTP_TLS=starttls
  #     SMTP_FROM=auth@vjlab.dev
  #     SMTP_USERNAME=your-smtp-user
  #     SMTP_PASSWORD=your-smtp-password
  #     LDAP_BIND_DN=uid=admin,ou=people,dc=vjlab,dc=dev
  #     LDAP_BIND_PASSWORD=your-ldap-bind-password
  #     LDAP_BASE_DN=dc=vjlab,dc=dev
  #     LDAP_USER_BASE_DN=ou=people,dc=vjlab,dc=dev
  #     LDAP_GROUP_BASE_DN=ou=groups,dc=vjlab,dc=dev
  sops.secrets.pocketid_env = {
    owner = "pocket-id";
    group = "pocket-id";
  };

  # ── Pocket ID service ─────────────────────────────────────────────────
  services.pocket-id = {
    enable = true;

    # Secrets via environment file (SMTP, LDAP credentials)
    environmentFile = config.sops.secrets.pocketid_env.path;

    settings = {
      # ── Core ──
      APP_URL = "https://auth.vjlab.dev";
      TRUST_PROXY = true;
      ANALYTICS_DISABLED = true;
      PORT = "1411";
      SESSION_DURATION = "1440";
      ACCENT_COLOR = "#0089E9";
      UI_CONFIG_DISABLED = "true";

      # ── Database (Unix socket, peer auth — no password needed) ──
      DB_CONNECTION_STRING = "postgresql:///pocket-id?host=/run/postgresql&port=${toString config.services.postgresql.settings.port}";

      # ── File storage ──
      FILE_BACKEND = "database";

      # ── LDAP (non-secret settings) ──
      LDAP_ENABLED = "true";
      LDAP_URL = "ldap://localhost:3890";
      LDAP_SOFT_DELETE_USERS = "true";
      LDAP_ADMIN_GROUP_NAME = "lldap_admin";
      LDAP_ATTRIBUTE_GROUP_MEMBER = "member";
      LDAP_ATTRIBUTE_GROUP_NAME = "cn";
      LDAP_ATTRIBUTE_GROUP_UNIQUE_IDENTIFIER = "uuid";
      LDAP_ATTRIBUTE_USER_EMAIL = "mail";
      LDAP_ATTRIBUTE_USER_FIRST_NAME = "first_name";
      LDAP_ATTRIBUTE_USER_LAST_NAME = "last_name";
      LDAP_ATTRIBUTE_USER_PROFILE_PICTURE = "avatar";
      LDAP_ATTRIBUTE_USER_UNIQUE_IDENTIFIER = "uuid";
      LDAP_ATTRIBUTE_USER_USERNAME = "user_id";

      # ── Email notifications ──
      EMAIL_API_KEY_EXPIRATION_ENABLED = "true";
      EMAIL_LOGIN_NOTIFICATION_ENABLED = "true";
      EMAIL_ONE_TIME_ACCESS_AS_ADMIN_ENABLED = "true";
      EMAIL_VERIFICATION_ENABLED = "true";
    };
  };

  # ── Service ordering = wait for PostgreSQL and LLDAP (healthy) ─────────
  systemd.services.pocket-id = {
    after = ["postgresql.service" "postgresql-setup.service" "lldap.service"];
    wants = ["postgresql.service" "lldap.service"];
    requires = ["postgresql-setup.service"];

    serviceConfig.ExecStartPost = pkgs.writeShellScript "pocket-id-healthcheck" ''
      echo "Waiting for Pocket ID to be healthy..."
      for i in {1..30}; do
        if ${config.services.pocket-id.package}/bin/pocket-id healthcheck; then
          echo "Pocket ID is healthy!"
          exit 0
        fi
        sleep 1
      done
      echo "Pocket ID healthcheck failed!"
      exit 1
    '';
  };

  # ── Nginx virtual host ──────────────────────────────────────────────────
  services.nginx.virtualHosts."auth.vjlab.dev" = {
    useACMEHost = "vjlab.dev";
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:1411";
    };
  };
}
