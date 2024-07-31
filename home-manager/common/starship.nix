{
  programs = {
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        command_timeout = 1000;
        format = ''
          $os$username$hostname$directory$cmd_duration
          [  └─>](bold green) '';
        status.disabled = false;
        username = {
          style_user = "white bold";
          style_root = "black bold";
          format = "[$user]($style) ";
          disabled = false;
          show_always = true;
        };
        hostname = {
          ssh_only = false;
          disabled = false;
          format = "on [$hostname](bold yellow) ";
          ssh_symbol = "@";
        };
        os = {
          format = "[$symbol](bold white) ";
          disabled = false;
          symbols = {
            Windows = "";
            Arch = "󰣇";
            Ubuntu = "";
            Macos = "󰀵";
          };
        };
        # Shows current git branch
        git_branch = {
          symbol = " ";
          format = "via [$symbol$branch]($style)";
          truncation_symbol = "…/";
          style = "bold green";
        };
        git_status = {
          format = "[$all_status$ahead_behind]($style) ";
          style = "bold green";
          conflicted = "🏳";
          up_to_date = "";
          untracked = " ";
          ahead = "⇡\${count}";
          diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
          behind = "⇣\${count}";
          stashed = " ";
          modified = " ";
          staged = "[++($count)](green)";
          renamed = "襁 ";
          deleted = " ";
        };
        kubernetes = {
          disabled = false;
          format = "via [󱃾 $context($namespace)](bold purple) ";
          detect_files = [ "k8s" ];
          detect_extensions = [ "yaml" ];
        };
        ocaml.disabled = true;
        perl.disabled = true;

        cmd_duration = {
          min_time = 500;
          show_notifications = true;
          min_time_to_notify = 600000;
          format = "took [$duration]($style) ";
        };

        directory = {
          truncation_length = 1;
          truncation_symbol = "…/";
          home_symbol = "󰋜 ~";
          read_only_style = "197";
          read_only = "  ";
          format = "at [$path]($style)[$read_only]($read_only_style) ";
        };

        # Cloud
        gcloud = {
          format = "on [$symbol($project)]($style) ";
        };

        # Icon changes only \/
        aws.symbol = "  ";
        conda.symbol = " ";
        dart.symbol = " ";
        docker_context.symbol = " ";
        elixir.symbol = " ";
        elm.symbol = " ";
        gcloud.symbol = " ";
        golang.symbol = " ";
        hg_branch.symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        memory_usage.symbol = " ";
        nim.symbol = " ";
        nodejs.symbol = " ";
        package.symbol = " ";
        perl.symbol = " ";
        php.symbol = " ";
        python.symbol = " ";
        ruby.symbol = " ";
        rust.symbol = " ";
        scala.symbol = " ";
        shlvl.symbol = "";
        swift.symbol = "ﯣ ";
        terraform.symbol = "行";
      };
    };
  };
}
