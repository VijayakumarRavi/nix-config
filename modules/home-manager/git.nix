{ pkgs, ... }: {
    programs.git = {
        enable = true;
        userName = "Vijayakumar Ravi";
        userEmail = "me@vijayakumar.xyz";
        extraConfig = {
            color.ui = "auto"; 
            pull.rebase = true;
            credential.helper = "osxkeychain";
            difftool.prompt = false;
            user.signingKey = "D0D2B010253E07C3";
            push = { 
                default = "simple";
                followTags = true;
                autoSetupRemote = true; 
            };
            commit = {
                gpgsign = true;
                template = "./gitmessage" ;
            };
            diff = {
                tool = "vimdiff";
                compactionHeuristic = true;
                indentHeuristic = true;
                colorMoved = "default";
                navigate = true;  # use n and N to move between diff sections
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
        ];
        aliases = {
            commit = "commit -S";
            a    = "add";
            b    = "branch";
            c    = "commit -S";
            d    = "difftool";
            m    = "mergetool";
            l    = "log";
            t    = "tag";
            ai   = "add -i";
            ci   = "commit -S";
            cp   = "cherry-pick";
            cs   = "commit --signoff";
            cm   = "commit -S --amend";
            co   = "checkout";
            dc   = "difftool --cached";
            fp   = "format-patch";
            lg   = "log --graph";
            lp   = "log --graph --pretty=format:'%Cred%h%Credreset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
            rb   = "rebase";
            ut   = "rm -r --cached";
            new  = "flow feature start";
            rel  = "flow release start";
            fix  = "flow hotfix start";
            undo = "reset --soft HEAD^";
            # Reset previous commit, but keep all the associated changes. Useful for avoiding nasty git merge commits.
            uncommit = "reset --soft HEAD^";
            unamend  = "reset --soft HEAD@{1}";
            abort    = "reset --hard HEAD^";
            new-end  = "flow feature finish";
            rel-end  = "flow release finish";
            fix-end  = "flow hotfix finish";
        };
    };
}
