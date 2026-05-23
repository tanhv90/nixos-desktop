{
  lib,
  config,
  pkgs,
  inputs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.neovim;
in
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  options.${namespace}.neovim = {
    enable = lib.mkEnableOption "Neovim (nixvim)";
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      defaultEditor = true;

      globals.mapleader = " ";

      opts = {
        number = true;
        relativenumber = true;
        shiftwidth = 2;
        tabstop = 2;
        expandtab = true;
        smartindent = true;
        undofile = true;
        ignorecase = true;
        smartcase = true;
        mouse = "a";
        clipboard = "unnamedplus";
        signcolumn = "yes";
      };

      extraPackages = with pkgs; [
        nixfmt
        prettierd
        ruff
        rustfmt
        stylua
        tree-sitter
      ];

      plugins = {
        lsp = {
          enable = true;
          servers = {
            rust_analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
            ts_ls.enable = true;
            phpactor.enable = true;
            gopls.enable = true;
            lua_ls.enable = true;
            nixd.enable = true;
            yamlls.enable = true;
            dockerls.enable = true;
            jsonls.enable = true;
          };
          keymaps = {
            diagnostic = {
              "<leader>j" = "goto_next";
              "<leader>k" = "goto_prev";
            };
            lspBuf = {
              "gd" = "definition";
              "gr" = "references";
              "gi" = "implementation";
              "K" = "hover";
              "<leader>rn" = "rename";
              "<leader>ca" = "code_action";
            };
          };
        };

        cmp = {
          enable = true;
          settings = {
            sources = [
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              { name = "path"; }
              { name = "buffer"; }
            ];
            mapping = {
              "<C-n>" = "cmp.mapping.select_next_item()";
              "<C-p>" = "cmp.mapping.select_prev_item()";
              "<C-y>" = "cmp.mapping.confirm({ select = true })";
              "<C-e>" = "cmp.mapping.abort()";
              "<C-Space>" = "cmp.mapping.complete()";
            };
          };
        };

        luasnip.enable = true;

        lspkind.enable = true;

        treesitter.enable = true;

        conform-nvim = {
          enable = true;
          settings = {
            formatters_by_ft = {
              nix = [ "nixfmt" ];
              lua = [ "stylua" ];
              python = [ "ruff_format" ];
              rust = [ "rustfmt" ];
              javascript = [ "prettierd" ];
              javascriptreact = [ "prettierd" ];
              typescript = [ "prettierd" ];
              typescriptreact = [ "prettierd" ];
              css = [ "prettierd" ];
              json = [ "prettierd" ];
              yaml = [ "prettierd" ];
              markdown = [ "prettierd" ];
              html = [ "prettierd" ];
            };
            format_on_save = {
              timeoutMs = 500;
              lspFallback = true;
            };
          };
        };

        lualine.enable = true;

        telescope = {
          enable = true;
          settings.defaults.mappings.i = {
            "<C-j>" = "move_selection_next";
            "<C-k>" = "move_selection_previous";
          };
        };

        gitsigns.enable = true;

        which-key.enable = true;

        web-devicons.enable = true;

        neo-tree = {
          enable = true;
          settings = {
            close_if_last_window = true;
            filesystem.filtered_items = {
              visible = true;
              hide_dotfiles = false;
            };
          };
        };

        trouble.enable = true;

        toggleterm = {
          enable = true;
          settings = {
            direction = "horizontal";
            size = 15;
            hide_numbers = true;
            autochdir = true;
          };
        };

        comment.enable = true;

        surround.enable = true;

        indent-blankline.enable = true;

        todo-comments.enable = true;

        oil.enable = true;

        undotree.enable = true;

        dap = {
          enable = true;
          extensions = {
            dap-ui.enable = true;
            dap-virtual-text.enable = true;
          };
        };
      };

      keymaps = [
        {
          key = "jj";
          action = "<C-\\><C-n>";
          mode = "t";
          options.desc = "Exit terminal mode";
        }
        {
          key = "<leader>t";
          action = "<cmd>ToggleTerm direction=\"horizontal\"<CR>";
          options.desc = "Terminal (bottom, 33%)";
        }
        {
          key = "<leader>tf";
          action = "<cmd>ToggleTerm direction=\"float\"<CR>";
          options.desc = "Terminal (floating)";
        }
        {
          key = "<leader>td";
          action = "<cmd>Telescope diagnostics<CR>";
          options.desc = "Diagnostics (popup list)";
        }
        {
          key = "<leader>xx";
          action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>";
          options.desc = "Toggle diagnostics (buffer)";
        }
        {
          key = "<leader>xw";
          action = "<cmd>Trouble diagnostics toggle<CR>";
          options.desc = "Toggle diagnostics (workspace)";
        }
        {
          key = "<leader>e";
          action = "<cmd>Neotree toggle<CR>";
          options.desc = "Toggle file tree";
        }
        {
          key = "-";
          action = "<cmd>Oil<CR>";
          options.desc = "Oil file explorer";
        }
        {
          key = "<leader>u";
          action = "<cmd>UndotreeToggle<CR>";
          options.desc = "Toggle undotree";
        }
        {
          key = "<leader>ff";
          action = "<cmd>Telescope find_files<CR>";
          options.desc = "Find files";
        }
        {
          key = "<leader>fg";
          action = "<cmd>Telescope live_grep<CR>";
          options.desc = "Live grep";
        }
        {
          key = "<leader>fb";
          action = "<cmd>Telescope buffers<CR>";
          options.desc = "Buffers";
        }
        {
          key = "<leader>fh";
          action = "<cmd>Telescope help_tags<CR>";
          options.desc = "Help tags";
        }
        {
          key = "<leader>db";
          action = "<cmd>DapToggleBreakpoint<CR>";
          options.desc = "Toggle breakpoint";
        }
        {
          key = "<leader>dc";
          action = "<cmd>DapContinue<CR>";
          options.desc = "Continue / start debug";
        }
        {
          key = "<leader>do";
          action = "<cmd>DapStepOver<CR>";
          options.desc = "Step over";
        }
        {
          key = "<leader>di";
          action = "<cmd>DapStepInto<CR>";
          options.desc = "Step into";
        }
        {
          key = "<leader>dr";
          action = "<cmd>DapToggleRepl<CR>";
          options.desc = "Toggle REPL";
        }
        {
          key = "<C-h>";
          action = "<C-w>h";
          options.desc = "Window left";
        }
        {
          key = "<C-j>";
          action = "<C-w>j";
          options.desc = "Window down";
        }
        {
          key = "<C-k>";
          action = "<C-w>k";
          options.desc = "Window up";
        }
        {
          key = "<C-l>";
          action = "<C-w>l";
          options.desc = "Window right";
        }
      ];
    };
  };
}
