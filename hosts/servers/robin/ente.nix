# Ente.io - End-to-end encrypted photo storage service
# Configures Ente's Museum API server and web frontends under the ente.vjlab.dev subdomain
{
  config,
  pkgs,
  ...
}: let
  # Helper to build custom Ente web client packages with the correct API origin endpoints
  webPackage = app:
    pkgs.ente-web.override {
      enteApp = app;
      enteMainUrl = "https://photos.ente.vjlab.dev";
      extraBuildEnv = {
        NEXT_PUBLIC_ENTE_ENDPOINT = "https://ente.vjlab.dev";
        NEXT_PUBLIC_ENTE_ALBUMS_ENDPOINT = "https://albums.ente.vjlab.dev";
        NEXT_TELEMETRY_DISABLED = "1";
      };
    };
in {
  # ── Sops secrets for Ente service ───────────────────────────────────────
  # Add to secrets.yaml (sops secrets.yaml):
  #   ente_jwt_secret: "your-jwt-secret"
  #   ente_key_encryption: "your-encryption-key"
  #   ente_key_hash: "your-key-hash"
  #   ente_s3_key: "your-idrive-access-key"
  #   ente_s3_secret: "your-idrive-secret-key"
  #   ente_s3_endpoint: "https://your-idrive-endpoint"
  #   ente_smtp_host: "your-smtp-host"
  #   ente_smtp_username: "your-smtp-username"
  #   ente_smtp_password: "your-smtp-password"
  #
  # Decrypted paths are mapped dynamically at runtime to Museum configuration
  sops.secrets.ente_jwt_secret = {
    owner = "ente";
    group = "ente";
  };
  sops.secrets.ente_key_encryption = {
    owner = "ente";
    group = "ente";
  };
  sops.secrets.ente_key_hash = {
    owner = "ente";
    group = "ente";
  };
  sops.secrets.ente_s3_key = {
    owner = "ente";
    group = "ente";
  };
  sops.secrets.ente_s3_secret = {
    owner = "ente";
    group = "ente";
  };
  sops.secrets.ente_s3_endpoint = {
    owner = "ente";
    group = "ente";
  };
  sops.secrets.ente_smtp_host = {
    owner = "ente";
    group = "ente";
  };
  sops.secrets.ente_smtp_username = {
    owner = "ente";
    group = "ente";
  };
  sops.secrets.ente_smtp_password = {
    owner = "ente";
    group = "ente";
  };

  # ── Ente Service Configurations ──────────────────────────────────────────
  services.ente = {
    # ── Museum (API server) ──
    api = {
      enable = true;
      domain = "ente.vjlab.dev";
      nginx.enable = true; # Enables default proxy virtualHost block

      user = "ente";
      group = "ente";

      # Local database settings (PostgreSQL peer auth via Unix Socket)
      enableLocalDB = false; # postgresql.nix manages database 'ente' and role 'ente'
      settings = {
        db = {
          host = "/run/postgresql";
          port = config.services.postgresql.settings.port; # 24957
          name = "ente";
          user = "ente";
          sslmode = "disable"; # Peer auth via local Unix socket does not require SSL
        };

        # Secret values injected at runtime from sops decrypted files
        jwt.secret._secret = config.sops.secrets.ente_jwt_secret.path;
        key.encryption._secret = config.sops.secrets.ente_key_encryption.path;
        key.hash._secret = config.sops.secrets.ente_key_hash.path;

        # Internal admin privileges
        internal = {
          admin = [1580559962386438];
        };

        # Object storage (IDrive S3)
        s3 = {
          are-local-buckets = false;
          use-path-style-urls = true;
          b2-eu-cen = {
            bucket = "ente";
            endpoint._secret = config.sops.secrets.ente_s3_endpoint.path;
            key._secret = config.sops.secrets.ente_s3_key.path;
            secret._secret = config.sops.secrets.ente_s3_secret.path;
            region = "us-west-1";
          };
        };

        # SMTP settings for outgoing emails
        smtp = {
          host._secret = config.sops.secrets.ente_smtp_host.path;
          port = 587;
          username._secret = config.sops.secrets.ente_smtp_username.path;
          password._secret = config.sops.secrets.ente_smtp_password.path;
          email._secret = config.sops.secrets.ente_smtp_username.path;
          sender-name = "Ente";
        };

        # Internal frontend endpoints
        apps = {
          custom-domain-cname = "ente.vjlab.dev";
          embed-albums = "https://embed.ente.vjlab.dev";
          public-locker = "https://share.ente.vjlab.dev";
          public-paste = "https://paste.ente.vjlab.dev";
          public-memories = "https://memories.ente.vjlab.dev";
        };
      };
    };

    # ── Ente Web Client Frontends ──
    web = {
      enable = true;
      domains = {
        # Set subdomains under the ente.vjlab.dev zone
        accounts = "accounts.ente.vjlab.dev";
        cast = "cast.ente.vjlab.dev";
        albums = "albums.ente.vjlab.dev";
        photos = "photos.ente.vjlab.dev";
      };
    };
  };

  # ── Nginx SSL Certificate Overrides ─────────────────────────────────────
  # Directs Nginx to use our wildcard certificate and forces SSL
  services.nginx.virtualHosts = {
    # API
    "ente.vjlab.dev" = {
      useACMEHost = "ente.vjlab.dev";
      forceSSL = true;
    };

    # Frontends (configured by services.ente.web)
    "photos.ente.vjlab.dev" = {
      useACMEHost = "ente.vjlab.dev";
      forceSSL = true;
    };
    "accounts.ente.vjlab.dev" = {
      useACMEHost = "ente.vjlab.dev";
      forceSSL = true;
    };
    "cast.ente.vjlab.dev" = {
      useACMEHost = "ente.vjlab.dev";
      forceSSL = true;
    };

    # Additional Ente web frontends (configured manually)
    "albums.ente.vjlab.dev" = {
      useACMEHost = "ente.vjlab.dev";
      forceSSL = true;
      locations."/" = {
        root = webPackage "albums";
        tryFiles = "$uri $uri.html /index.html";
        extraConfig = "add_header Access-Control-Allow-Origin 'https://ente.vjlab.dev';";
      };
    };
    "share.ente.vjlab.dev" = {
      useACMEHost = "ente.vjlab.dev";
      forceSSL = true;
      locations."/" = {
        root = webPackage "share";
        tryFiles = "$uri $uri.html /index.html";
        extraConfig = "add_header Access-Control-Allow-Origin 'https://ente.vjlab.dev';";
      };
    };
    "embed.ente.vjlab.dev" = {
      useACMEHost = "ente.vjlab.dev";
      forceSSL = true;
      locations."/" = {
        root = webPackage "embed";
        tryFiles = "$uri $uri.html /index.html";
        extraConfig = "add_header Access-Control-Allow-Origin 'https://ente.vjlab.dev';";
      };
    };
    "auth.ente.vjlab.dev" = {
      useACMEHost = "ente.vjlab.dev";
      forceSSL = true;
      locations."/" = {
        root = webPackage "auth";
        tryFiles = "$uri $uri.html /index.html";
        extraConfig = "add_header Access-Control-Allow-Origin 'https://ente.vjlab.dev';";
      };
    };
    "paste.ente.vjlab.dev" = {
      useACMEHost = "ente.vjlab.dev";
      forceSSL = true;
      locations."/" = {
        root = webPackage "paste";
        tryFiles = "$uri $uri.html /index.html";
        extraConfig = "add_header Access-Control-Allow-Origin 'https://ente.vjlab.dev';";
      };
    };
    "locker.ente.vjlab.dev" = {
      useACMEHost = "ente.vjlab.dev";
      forceSSL = true;
      locations."/" = {
        root = webPackage "locker";
        tryFiles = "$uri $uri.html /index.html";
        extraConfig = "add_header Access-Control-Allow-Origin 'https://ente.vjlab.dev';";
      };
    };
    "memories.ente.vjlab.dev" = {
      useACMEHost = "ente.vjlab.dev";
      forceSSL = true;
      locations."/" = {
        root = webPackage "memories";
        tryFiles = "$uri $uri.html /index.html";
        extraConfig = "add_header Access-Control-Allow-Origin 'https://ente.vjlab.dev';";
      };
    };
  };

  # ── Environment Origins & Startup Ordering ──────────────────────────────
  systemd.services.ente = {
    after = ["postgresql.service" "postgresql-setup.service"];
    wants = ["postgresql.service"];
    requires = ["postgresql-setup.service"];

    environment = {
      ENTE_ALBUMS_ORIGIN = "https://albums.ente.vjlab.dev";
      ENTE_API_ORIGIN = "https://ente.vjlab.dev";
      ENTE_PHOTOS_ORIGIN = "https://photos.ente.vjlab.dev";
    };
  };
}
