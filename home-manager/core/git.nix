{
  lib,
  config,
  variables,
  ...
}: {
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
    rm -fv ${config.home.homeDirectory}/.gitconfig
  '';
  programs.git = {
    enable = true;
    userName = variables.user;
    userEmail = variables.useremail;
    signing = {
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII8O84V4KrHZGAtdgY9vTYOGdH/BPcI846sM+MbCYuLX";
      signByDefault = true;
    };
    # Diff tool
    delta = {
      enable = true;
      options = {
        navigate = true;
        line-numbers = true;
        side-by-side = true;
        diff-so-fancy = true;
        true-color = "always";
      };
    };
    extraConfig = {
      color.ui = "auto";
      pull.rebase = true;
      pull.autostash = true;
      rebase.autostash = true;
      credential.helper = "osxkeychain";
      difftool.prompt = false;
      init.defaultBranch = "master";
      core = {
        editor = "nvim";
      };
      push = {
        default = "current";
        followTags = true;
        autoSetupRemote = true;
      };
      merge = {
        prompt = false;
        autostash = true;
        tool = "nvimdiff4";
        conflictstyle = "diff3";
      };
      mergetool.nvimdiff4 = {
        cmd = "nvim -d $LOCAL $BASE $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";
      };
      gpg = {
        format = "ssh";
      };
      commit = {
        gpgsign = true;
        template = "./gitmessage";
      };
      diff = {
        colorMoved = "default";
      };
      # replace https with ssh
      # url = {
      #   "ssh://git@github.com/" = {
      #     insteadOf = "https://github.com/";
      #   };
      #   "ssh://git@gitlab.com/" = {
      #     insteadOf = "https://gitlab.com/";
      #   };
      # };
    };
    aliases = {
      a = "add";
      l = "log";
      t = "tag";
      ai = "add -i";
      b = "branch";
      d = "difftool";
      m = "mergetool";
      cp = "cherry-pick";
      co = "checkout";
      fp = "format-patch";
      lg = "log --graph";
      dc = "difftool --cached";
      commit = "commit --signoff -S";
      cm = "commit -S --signoff --amend";
      c = "commit -S --signoff --no-verify -m";
      lp = "log --graph --pretty=format:'%Cred%h%Credreset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      rb = "rebase";
      ut = "rm -r --cached";
      undo = "reset --soft HEAD^";
      # Reset previous commit, but keep all the associated changes. Useful for avoiding nasty git merge commits.
      uncommit = "reset --soft HEAD^";
      unamend = "reset --soft HEAD@{1}";
      abort = "reset --hard HEAD^";
      foreach = "submodule foreach";
      update = "submodule update --init --recursive";

      # delete merged branches except master & dev & staging
      #  `!` indicates it's a shell script, not a git subcommand
      delmerged = ''! git branch --merged | egrep -v "(^\*|main|master|dev|staging)" | xargs git branch -d'';
      # delete non-exist(remote) branches
      delnonexist = "remote prune origin";
    };
  };
}
