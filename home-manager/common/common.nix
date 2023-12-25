{ pkgs, ... }: {
    programs ={ 
        zoxide = { # smarter cd command
          enable = true;
          enableZshIntegration = true;
        };
        fzf = { 
            enable = true; # Fuzzy finder
            enableZshIntegration = true; 
        };
        direnv = {
            enable = true;
            nix-direnv.enable = true;
        };
        gh = {
            enable = true; # GitHub CLI
            extensions = with pkgs; [gh-markdown-preview];
            settings = {
                git_protocol = "ssh";
                prompt = "enabled";
            };
        };
        ssh = {
            enable = true;
            matchBlocks = {
                "*" = {
                    extraOptions = {
                        IdentityAgent = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
                    };
                };
            };
            extraConfig = ''
                Host pi
                    HostName 10.0.0.3
                    User pi
                    Port 22
                Host pve
                    HostName 10.0.0.7
                    User root
                    Port 22
                Host nix
                    HostName 10.0.1.5
                    User vijay
                    Port 22
            '';
        };
    };
}
