{
  lib,
  config,
  pkgs,
  namespace,
  ...
}:
let
  cfg = config.${namespace}.helix;
in
{
  options.${namespace}.helix = {
    enable = lib.mkEnableOption "Helix editor";
  };

  config = lib.mkIf cfg.enable {
    programs.helix = {
      enable = true;

      # Helix auto-detects LSP servers from PATH — this mirrors the servers
      # enabled in the nixvim module so both editors cover the same languages.
      extraPackages = with pkgs; [
        nixd
        rust-analyzer
        gopls
        typescript-language-server
        lua-language-server
        yaml-language-server
        dockerfile-language-server
        vscode-langservers-extracted
        marksman
        phpactor
        bash-language-server
        taplo
        clang-tools
        ty
        ruff

        # Formatters invoked directly by Helix (see languages.language below).
        nixfmt
        stylua
        prettier
        shfmt

        # Debug adapters: lldb-dap for c/cpp/rust, dlv for go.
        lldb
        delve
      ];

      languages = {
        # Helix ships defaults for these, but pin the commands so a server
        # rename upstream cannot silently disable the language.
        language-server = {
          nixd.command = "nixd";
          phpactor = {
            command = "phpactor";
            args = [ "language-server" ];
          };
          ruff = {
            command = "ruff";
            args = [ "server" ];
          };
        };

        language =
          let
            prettier = filename: {
              command = "prettier";
              args = [
                "--stdin-filepath"
                filename
              ];
            };
          in
          [
            {
              # Helix defaults to nil; nixd is what the nixvim module uses.
              name = "nix";
              language-servers = [ "nixd" ];
              formatter.command = "nixfmt";
              auto-format = true;
            }
            {
              # Helix defaults to intelephense, which is unfree.
              name = "php";
              language-servers = [ "phpactor" ];
            }
            {
              name = "python";
              language-servers = [
                "ty"
                "ruff"
              ];
              formatter = {
                command = "ruff";
                args = [
                  "format"
                  "-"
                ];
              };
              auto-format = true;
            }
            {
              name = "bash";
              formatter = {
                command = "shfmt";
                args = [
                  "-i"
                  "2"
                ];
              };
              auto-format = true;
            }
            {
              name = "lua";
              formatter = {
                command = "stylua";
                args = [ "-" ];
              };
              auto-format = true;
            }
            {
              name = "json";
              formatter = prettier "file.json";
              auto-format = true;
            }
            {
              name = "yaml";
              formatter = prettier "file.yaml";
              auto-format = true;
            }
            {
              name = "markdown";
              formatter = prettier "file.md";
              auto-format = true;
            }
            {
              name = "html";
              formatter = prettier "file.html";
              auto-format = true;
            }
            {
              name = "css";
              formatter = prettier "file.css";
              auto-format = true;
            }
            {
              name = "javascript";
              formatter = prettier "file.js";
              auto-format = true;
            }
            {
              name = "jsx";
              formatter = prettier "file.jsx";
              auto-format = true;
            }
            {
              name = "typescript";
              formatter = prettier "file.ts";
              auto-format = true;
            }
            {
              name = "tsx";
              formatter = prettier "file.tsx";
              auto-format = true;
            }
          ];
      };

      settings = {
        editor = {
          line-number = "relative";
          mouse = true;
          true-color = true;

          bufferline = "always";

          soft-wrap.enable = true;

          indent-guides.render = true;

          # Show dotfiles in the picker (same as neovim's neo-tree setup).
          # Lives under editor since Helix 25.x.
          file-picker.hidden = false;
        };

        keys.normal.tab = ":buffer-next";
        keys.normal."S-tab" = ":buffer-previous";

        # Open yazi as a file picker for the current buffer, then jump to the
        # chosen file.
        keys.normal."C-y" = [
          ":sh rm -f /tmp/unique-ca1ea106"
          ":insert-output yazi \"%{buffer_name}\" --chooser-file=/tmp/unique-ca1ea106"
          ":sh printf \"\\x1b[?1049h\\x1b[?2004h\" > /dev/tty"
          ":open %sh{cat /tmp/unique-ca1ea106}"
          ":redraw"
          ":set mouse false"
          ":set mouse true"
        ];
      };
    };
  };
}
