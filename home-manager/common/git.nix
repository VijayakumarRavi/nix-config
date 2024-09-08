{variables, ...}: {
  programs.git = {
    enable = true;
    userName = variables.user;
    userEmail = variables.useremail;
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    delta.enable = true; # Diff tool
    delta.options = {
      line-numbers = true;
      side-by-side = true;
      navigate = true;
    };
    extraConfig = {
      color.ui = "auto";
      pull.rebase = true;
      rebase.autoStash = true;
      merge.autostash = true;
      credential.helper = "osxkeychain";
      difftool.prompt = false;
      # user.signingKey = "~/.ssh/id_ed25519.pub";
      push = {
        default = "current";
        followTags = true;
        autoSetupRemote = true;
      };
      gpg = {
        format = "ssh";
      };
      commit = {
        # gpgsign = true;
        template = "./gitmessage";
      };
      diff = {
        colorMoved = "default";
        # tool = "vimdiff";
        # compactionHeuristic = true;
        # indentHeuristic = true;
        # navigate = true; # use n and N to move between diff sections
        # renames = "copies";
      };
    };
    aliases = {
      commit = "commit --signoff -S";
      a = "add";
      b = "branch";
      c = "commit -S --signoff";
      d = "difftool";
      m = "mergetool";
      l = "log";
      t = "tag";
      ai = "add -i";
      cp = "cherry-pick";
      cm = "commit -S --signoff --amend";
      co = "checkout";
      dc = "difftool --cached";
      fp = "format-patch";
      lg = "log --graph";
      lp = "log --graph --pretty=format:'%Cred%h%Credreset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      rb = "rebase";
      ut = "rm -r --cached";
      new = "flow feature start";
      rel = "flow release start";
      fix = "flow hotfix start";
      undo = "reset --soft HEAD^";
      # Reset previous commit, but keep all the associated changes. Useful for avoiding nasty git merge commits.
      uncommit = "reset --soft HEAD^";
      unamend = "reset --soft HEAD@{1}";
      abort = "reset --hard HEAD^";
      new-end = "flow feature finish";
      rel-end = "flow release finish";
      fix-end = "flow hotfix finish";
    };
  };
}
