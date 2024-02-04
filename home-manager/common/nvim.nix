# { nixvim, ... }: {
{ inputs, ... }: {
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";

    options = {
      # Enable line numbers
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers

      # Disable text wrap
      wrap = false;

      # Set tabs to 2 spaces
      tabstop = 2;
      softtabstop = 2;
      expandtab = true;

      # Enable auto indenting and set it to spaces
      shiftwidth = 2;
      autoindent = true;
      smartindent = true;
      # Enable smart indenting (see https://stackoverflow.com/questions/1204149/smart-wrap-in-vim)
      breakindent = true;

      # Enable the sign column to prevent the screen from jumping
      signcolumn = "yes";

      # Enable incremental searching
      hlsearch = false;
      incsearch = true;

      # Enable ignorecase + smartcase for better searching
      ignorecase = true;
      smartcase = true;

      # Enable 24-bit color
      termguicolors = true;

      #  Enable cursor line highlight
      cursorline = true;

      # Always keep 10 lines above/below cursor unless at start/end of file
      scrolloff = 10;

      # Enable spell check
      spell = true;
      spelllang = [ "en_us" ];
    };

    # Set colorschemes to catppuccin
    colorschemes.catppuccin = {
      enable = true;
      background.dark = "macchiato";
      background.light = "macchiato";
      transparentBackground = true;
      integrations.telescope.enabled = true;
      integrations.native_lsp.enabled = true;
      integrations.harpoon = true;
      integrations.neotree = true;
      integrations.treesitter = true;
      integrations.cmp = true;
    };

    # Enable access to System Clipboard
    clipboard.register = [ "unnamedplus" "unnamed" ];

    # Enable persistent undo history
    extraConfigVim = ''
      if has("persistent_undo")
        let target_path = expand('~/.cache/undodir')

         " create the directory and any parent directories
         " if the location does not exist.
         if !isdirectory(target_path)
             call mkdir(target_path, "p", 0700)
         endif

         let &undodir=target_path
         set undofile
      endif
    '';

    # Remember last cursor position
    # When editing a file, always jump to the last known cursor position.
    # Don't do it when the position is invalid, when inside an event handler,
    # for a commit or rebase message
    # (likely a different one than last time), and when using xxd(1) to filter
    # and edit binary files (it transforms input files back and forth, causing
    # them to have dual nature, so to speak)
    extraConfigLua = ''
      function RestoreCursorPosition()
        local line = vim.fn.line("'\"")
        if
            line > 1
            and line <= vim.fn.line("$")
            and vim.bo.filetype ~= "commit"
            and vim.fn.index({ "xxd", "gitrebase" }, vim.bo.filetype) == -1
        then
          vim.cmd('normal! g`"')
        end
      end

      if vim.fn.has("autocmd") then
        vim.cmd([[
          autocmd BufReadPost * lua RestoreCursorPosition()
        ]])
      end
    '';

    keymaps = [
      {
        # Control-s to save a file
        action = "<esc>:w<cr>";
        key = "<C-s>";
        mode = [ "n" "i" "v" ];
      }
      {
        action = ":nohlsearch<CR>";
        key = "<leader>h";
        mode = [ "n" "i" "v" ];
      }
      { # Neotree toggle
        action = ":Neotree toggle<CR>";
        key = "<C-n>";
        mode = [ "n" ];
      }
      {
        action = ":Neotree buffers reveal float<CR>";
        key = "<leader>bf";
        mode = [ "n" ];
      }
      { # Open oil
        action = ":Oil<CR>";
        key = "-";
        mode = [ "n" ];
      }
      # Lsp
      {
        action = "vim.lsp.buf.hover";
        lua = true;
        key = "<C-h>";
        mode = [ "n" ];
      }
      {
        action = "vim.lsp.buf.definition";
        lua = true;
        key = "<leader>gd";
        mode = [ "n" ];
      }
      {
        action = "vim.lsp.buf.references";
        lua = true;
        key = "<leader>gr";
        mode = [ "n" ];
      }
      {
        action = "vim.lsp.buf.code_action";
        lua = true;
        key = "<leader>ca";
        mode = [ "n" ];
      }
      #  Navigate vim panes better
      {
        action = ":wincmd k<CR>";
        key = "<C-k>";
        mode = [ "n" ];
      }
      {
        action = ":wincmd j<CR>";
        key = "<C-j>";
        mode = [ "n" ];
      }
      {
        action = ":wincmd h<CR>";
        key = "<C-h>";
        mode = [ "n" ];
      }
      {
        action = ":wincmd l<CR>";
        key = "<C-l>";
        mode = [ "n" ];
      }
      { # Telescope Undo history
        action = "<cmd>Telescope undo<cr>";
        key = "<leader>u";
        mode = [ "n" "i" "v" ];
      }

    ];

    # plugins
    plugins = {
      alpha = {
        enable = true;
        iconsEnabled = true;
        theme = "dashboard";
      };

      lualine = { enable = true; };

      gitsigns = { enable = true; };

      leap.enable = true;

      nix.enable = true;

      harpoon = {
        enable = true;
        enableTelescope = true;
        markBranch = true;
        #extraOptions = { ''vim.keymap.set("n", "R", ":lua require("harpoon.mark").clear_all()<CR>", {})''; };
        keymaps = {
          addFile = "A";
          toggleQuickMenu = "H";
          navPrev = "K";
          navNext = "j";
          navFile = {
            "1" = "!";
            "2" = "@";
            "3" = "#";
            "4" = "$";
            "5" = "%";
            "6" = "^";
            "7" = "&";
            "8" = "*";
            "9" = "(";
            "0" = ")";
          };
        };
      };

      telescope = {
        enable = true;
        extensions.undo = { enable = true; };
        keymaps = {
          "<C-p>" = {
            action = "find_files";
            desc = "Telescope Find Files";
          };
          "<leader>fg" = "live_grep";
        };
      };

      neo-tree = {
        enable = true;
        window.width = 30;
        closeIfLastWindow = true;
      };

      oil = {
        enable = true;
        promptSaveOnSelectNewEntry = false;
        viewOptions.showHidden = true;
        columns = {
          icon.enable = true;
          size.enable = true;
          type.enable = true;
        };
      };

      treesitter = {
        enable = true;
        indent = true;
        nixGrammars = true;
      };

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          lua-ls = {
            enable = true;
            settings.telemetry.enable = false;
          };
        };
      };

      cmp-path.enable = true;
      cmp-spell.enable = true;
      cmp_luasnip.enable = true;
      cmp-nvim-lsp.enable = true;
      cmp-cmdline.enable = true;
      cmp-cmdline-history.enable = true;
      nvim-cmp = {
        enable = true;
        autoEnableSources = true;
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "spell"; }
          { name = "buffer"; }
          { name = "luasnip"; }
        ];
        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
          "<C-Space>" = "cmp.mapping.complete()";
          "<Tab>" = {
            action = ''
              function(fallback)
                if cmp.visible() then
                  cmp.select_next_item()
                elseif luasnip.expandable() then
                  luasnip.expand()
                elseif luasnip.expand_or_jumpable() then
                  luasnip.expand_or_jump()
                elseif check_backspace() then
                  fallback()
                else
                  fallback()
                end
              end
            '';
            modes = [ "i" "s" ];
          };
        };
      };

      conform-nvim = {
        enable = true;
        formatOnSave = {
          lspFallback = true;
          timeoutMs = 500;
        };
        # Map of filetype to formatters
        formattersByFt = {
          lua = [ "stylua" ];
          nix = [ "nixfmt" ];
          terraform = [ "terraform_fmt" ];
          # Use the "*" filetype to run formatters on all filetypes.
          "*" = [ "codespell" "trim_whitespace" ];
          # Use the "_" filetype to run formatters on filetypes that don't
          # have other formatters configured.
          # example: "_" = [ "trim_whitespace" ];
        };
      };
    };
  };
}
