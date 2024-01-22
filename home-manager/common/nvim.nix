# { nixvim, ... }: {
{ inputs, ... }: {
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";

    options = {
      number = true; # Show line numbers
      relativenumber = true; # Show relative line numbers
      expandtab = true;
      softtabstop = 2;
      shiftwidth = 2; # Tab width should be 2
      autoindent = true;
      smartindent = true;
      hlsearch = false;
      incsearch = true;
      ignorecase = true;
      scrolloff = 10;
      spell = true;
      spelllang = [ "en_us" ];
    };

    colorschemes.catppuccin = {
      enable = true;
      background.dark = "macchiato";
      background.light = "macchiato";
    };

    clipboard.register = "unnamedplus";

    extraConfigLua = ''
      -- last cursor position
      -- When editing a file, always jump to the last known cursor position.
      -- Don't do it when the position is invalid, when inside an event handler,
      -- for a commit or rebase message
      -- (likely a different one than last time), and when using xxd(1) to filter
      -- and edit binary files (it transforms input files back and forth, causing
      -- them to have dual nature, so to speak)
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
      {
        # Neotree toggle
        action = ":Neotree toggle<CR>";
        key = "<C-n>";
        mode = [ "n" ];
      }
      {
        action = ":Neotree buffers reveal float<CR>";
        key = "<leader>bf";
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

    ];

    # plugins
    plugins = {
      lualine = { enable = true; };

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
        closeIfLastWindow = true;
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
      # cmp-look
      cmp-spell.enable = true;
      cmp_luasnip.enable = true;
      cmp-nvim-lsp.enable = true;
      friendly-snippets.enable = true;

      nvim-cmp = {
        enable = true;
        autoEnableSources = true;
        sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
          { name = "luasnip"; }
        ];

        mapping = {
          "<CR>" = "cmp.mapping.confirm({ select = true })";
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
