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
          
          historySubstringSearch = {
            enable = true;
          };

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

          function pullall() {
            for i in `git remote`; do 
              git pull $i;
            done;
          }
          '';

        shellAliases = {
            nixswitch = "darwin-rebuild switch --flake /Users/vijay/Developer/Github/nix-config#";
            nixup = "pushd /Users/vijay/Developer/Github/nix-config; nix flake update; nixswitch; popd";
            # System Aliases
            rm="rm -vr";
            cp="cp -vr";
            rsync="rsync --progress";
            mv="mv -v";
            mkdir="mkdir -pv";
            SS="sudo systemctl";
            ls="gls -hAN --color=auto --group-directories-first";
            ll="gls -lhAv --color=auto --group-directories-first";
            grep="grep --color=auto";
            h="history";
            j="jobs -l";
            which="type -a";
            du="du -kh";    # Makes a more readable output.
            df="df -kTh";

            # For ease of use shortcuts
            q="exit";
            ":q"="exit";
            c="clear";
            r="ranger";
            ",,"="cd -";
            ".."="cd ..";
            "..."="cd ../..";
            n="nvim";
            sn="sudo nvim";
            vim="nvim";
            svi="sudo vim";
            lzd="lazydocker";
            lzg="lazygit";
            pg="ping google.com";
            pv="ping vijayakumar.xyz";
            ncspotd="ncspot -d ~/.config/ncspot/DEBUG";
            helix="/home/vijay/Downloads/helix.AppImage";
            tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale";
            ping="prettyping";
            preview="fzf --preview 'cat {}'";
            # Edit configs
            nrc="vim ~/.config/nvim/init.lua";
            vimrc="vim ~/.vimrc";
            bashrc="vim ~/.bashrc";
            i3con="vim ~/.config/i3/config";
            loadbash="source ~/.bashrc";
            notes="vim ~/.notes.txt";
            # Git
            gs="git status";
            gc="git clone --depth=1 --recursive";
            dot="/usr/bin/git --git-dir=$HOME/.local/share/dotfiles/ --work-tree=$HOME";
            addup="git add -u";
            ga="git add";
            gall="git add .";
            branch="git branch";
            checkout="git checkout";
            clone="git clone";
            commit="git cz --name cz_commitizen_emoji commit -s";
            fetch="git fetch";
            tag="git tag";
            newtag="git tag -a";

        };
    };
}
