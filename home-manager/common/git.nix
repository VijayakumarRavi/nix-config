{variables, ...}: {
  programs.git = {
    enable = true;
    userName = variables.user;
    userEmail = variables.useremail;
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
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
        default = "simple";
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
        tool = "vimdiff";
        compactionHeuristic = true;
        indentHeuristic = true;
        colorMoved = "default";
        navigate = true; # use n and N to move between diff sections
        renames = "copies";
      };
    };
    ignores = [
      ".idea"
      ".vs"
      ".vsc"
      ".vscode" # ide
      ".DS_Store" # mac
      "node_modules"
      "npm-debug.log" # npm
      "__pycache__"
      "*.pyc" # python
      ".ipynb_checkpoints" # jupyter
      "__sapper__" # svelte
      "*.DS_Store"
      ".DS_Store"
      "*.sw[nop]"
      ".bundle"
      ".env"
      "db/*.sqlite3"
      "log/*.log"
      "rerun.txt"
      "tmp/**/*"
      "!tmp/cache/.keep"
      "zeus.json"
      ".svn"
      "*.swp"
      "*.rbc"
      "**/plugged"
      "**/.init.vim*"
      ".tern-project"
      ".tern-port"
      "Procfile"
      "node_modules"
      ".nyc_output"
      "**/db/structure.sql"
      "bin/rails"
      "bin/rake"
      "bin/rspec"
      "deps"
      "_build"
      ".elixir_ls"
      "credo_extra"
      "elm-stuff"
      "rel"
      "**/stderr_log"
      "**/output.txt"
      "**/repl*.elm"
      ".ccls-cache"
      ".git"
      "**/.git"
      "*.dot"
      "Brewfile.lock.json"

      "node_modules"
      "[._]*.s[a-w][a-z]"
      "[._]s[a-w][a-z]"
      "*~"
      "tags"
      "tags.lock"
      "tags.temp"
      ".tags"
      "vim-markdown-preview.html"
      "*.un~"
      "Session.vim"
      ".xmark.README.md.html"
      # Compiled source #
      ###################"
      "*.com"
      "*.class"
      "*.dll"
      "*.o"
      "*.so"
      ".lvimrc"
      ".idea"

      # Logs and databases #
      ######################"
      "*.log"
      "*.sqlite"

      # OS generated files #
      ######################"
      ".DS_Store"
      ".DS_Store?"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      "ehthumbs.db"
      "Thumbs.db"
      "gin-bin"
      ".tern-port"

      # Oni Config Dir #
      ".oni"

      # VSCode workspaces
      "*.code-workspace"
      ".vscode"
      ":merlin-log:"
      "*.doc#"

      "CMakeLists.txt.user"
      "CMakeCache.txt"
      "CMakeFiles"
      "CMakeScripts"
      "Testing"
      "cmake_install.cmake"
      "install_manifest.txt"
      "compile_commands.json"
      "CTestTestfile.cmake"
      "_deps"
      ".vim/"
      "*.add.spl"
      ".vim-spell-en.utf-8.add.spl"
      ".nvimrc"
      ".projections.json"
      ".classpath"
      ".factorypath"
      ".settings/"

      # Vim Wiki tag files
      ".vimwiki_tags"

      ".localrc.lua"
      ".exrc"
      ".ignore"
      ".yarn"

      ".worktrees"
    ];
    aliases = {
      commit = "commit --signoff -S";
      a = "add";
      b = "branch";
      c = "commit -S";
      d = "difftool";
      m = "mergetool";
      l = "log";
      t = "tag";
      ai = "add -i";
      ci = "commit -S";
      cp = "cherry-pick";
      cs = "commit --signoff";
      cm = "commit -S --amend";
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
