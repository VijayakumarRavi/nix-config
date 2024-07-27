{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    dotDir = ".config/zsh";

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreSpace = true; # ignore commands starting with a space
      save = 2000000;
      size = 2000000;
      share = true;
    };

    historySubstringSearch = {
      enable = true;
    };

    initExtra = ''
      function switch() {
        if command -v darwin-rebuild &> /dev/null 2>&1; then
          darwin-rebuild switch "$@" -L --flake /Users/vijay/.nix-config#kakashi
        else
          sudo nixos-rebuild switch "$@" --accept-flake-config --flake /home/vijay/.nix-config#zoro
        fi
      }

      function gsync() {
        for i in `git remote`; do
          git pull $i `git branch --show-current`;
        done;

        for i in `git remote`; do
          git push $i `git branch --show-current`;
        done;
      }

      [ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh
    '';

    shellAliases = {
      # System Aliases
      rm = "rm -vr";
      cp = "cp -vr";
      mv = "mv -v";
      du = "du -kh"; # Makes a more readable output.
      df = "df -kTh";
      which = "type -a";
      mkdir = "mkdir -pv";
      SS = "sudo systemctl";
      grep = "grep --color=auto";
      rsync = "${pkgs.rsync}/bin/rsync --progress";
      ls = "${pkgs.lsd}/bin/lsd -hA --color=auto --group-directories-first";
      ll = "${pkgs.lsd}/bin/lsd -lhAv --color=auto --group-directories-first";

      # For ease of use shortcuts
      q = "exit";
      ":q" = "exit";
      c = "clear";
      ",," = "cd -";
      ".." = "cd ..";
      "..." = "cd ../..";
      n = "nvim";
      sn = "sudo nvim";
      sv = "sudo vim";
      pg = "prettyping google.com";
      pv = "prettyping vijayakumar.xyz";
      lg = "${pkgs.lazygit}/bin/lazygit";
      ld = "${pkgs.lazydocker}/bin/lazydocker";
      ncspotd = "${pkgs.ncspot}/bin/ncspot -d ~/.config/ncspot/DEBUG";

      # tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      pping = "prettyping";
      notes = "nvim ~/.notes.txt";
      preview = "${pkgs.fzf}/bin/fzf --preview 'cat {}'";

      # Git
      ga = "git add";
      gs = "git status";
      gall = "git add .";
      addup = "git add -u";
      commit = "git commit --signoff -S -m";
      gc = "git clone --depth=1 --recursive";

      # Docker container
      ds = "sudo docker start";
      dsp = "sudo docker stop";
      dre = "sudo docker restart";
      dlog = "sudo docker logs -f";
      dex = "sudo docker exec -it";
      dps = "sudo docker ps -a";
      dst = "sudo docker stats";
      dprune = "sudo docker system prune -a -f";

      # docker Compose up
      dcup = "sudo docker compose up -d";
      dcdown = "sudo docker compose down";
      dclog = "sudo docker compose logs -f";
      dcps = "sudo docker compose ps -a";
      dcpull = "sudo docker compose pull";
      dcst = "sudo docker compose stats";
      dcprune = "sudo docker compose down --remove-orphans --volumes --rmi all";
    };
  };
}
