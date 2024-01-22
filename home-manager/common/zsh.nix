{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
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

    historySubstringSearch = { enable = true; };

    initExtra = ''
      function cd() {
        builtin cd $*
        ${pkgs.lsd}/bin/lsd
      }

      function pushall() {
        for i in `git remote`; do
          git push $i;
        done;
      }

      function switch() {
        if command -v darwin-rebuild &> /dev/null 2>&1; then
          darwin-rebuild switch "$@" -L --flake /Users/vijay/.nix-config#kakashi
        else
          sudo nixos-rebuild switch "$@" -L --accept-flake-config --flake /home/vijay/.nix-config#zoro
        fi
      }

      function pullall() {
        for i in `git remote`; do
          git pull $i;
        done;
      }

      [ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh
    '';

    shellAliases = {
      nixup = "pushd /Users/vijay/.nix-config; nix flake update; nixswitch; popd";
      # System Aliases
      rm = "rm -vr";
      cp = "cp -vr";
      rsync = "${pkgs.rsync} --progress";
      mv = "mv -v";
      mkdir = "mkdir -pv";
      SS = "sudo systemctl";
      ls = "${pkgs.lsd}/bin/lsd -hA --color=auto --group-directories-first";
      ll = "${pkgs.lsd}/bin/lsd -lhAv --color=auto --group-directories-first";
      grep = "grep --color=auto";
      h = "history";
      j = "jobs -l";
      which = "type -a";
      du = "du -kh"; # Makes a more readable output.
      df = "df -kTh";

      # For ease of use shortcuts
      q = "exit";
      ":q" = "exit";
      c = "clear";
      r = "ranger";
      ",," = "cd -";
      ".." = "cd ..";
      "..." = "cd ../..";
      n = "nvim";
      sn = "sudo nvim";
      sv = "sudo vim";
      lzd = "${pkgs.lazydocker}";
      lzg = "${pkgs.lazygit}";
      pg = "prettyping google.com";
      pv = "prettyping vijayakumar.xyz";
      ncspotd = "${pkgs.ncspot} -d ~/.config/ncspot/DEBUG";

     # tailscale = "/Applications/Tailscale.app/Contents/MacOS/Tailscale";
      pping = "prettyping";
      preview = "${pkgs.fzf} --preview 'cat {}'";
      notes = "nvim ~/.notes.txt";
      
# Git
      gs = "git status";
      gc = "git clone --depth=1 --recursive";
      addup = "git add -u";
      ga = "git add";
      gall = "git add .";
      commit = "git cz --name cz_emoji commit -s";
    };
  };
}
