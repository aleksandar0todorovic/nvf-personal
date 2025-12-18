{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:NixOS/nixpkgs/master";
    nvf.url = "github:notashelf/nvf";
  };

  outputs = {
    nixpkgs,
    nvf,
    ...
  } @ inputs: let
    # Supported systems
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems f;

    mkNeovimConfig = _: system: let
      pkgs = import nixpkgs {inherit system;};
    in
      nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [
          {
            config.vim = {
              theme = {
                enable = true;
                name = "catppuccin";
                style = "macchiato";
              };

              autocmds = [
                {
                  callback =
                    nixpkgs.lib.generators.mkLuaInline
                    ''
                      function()
                        require("lint").try_lint()
                      end
                    '';
                  desc = "Try lint on certain events";
                  event = ["BufEnter" "BufWritePost" "InsertLeave"];
                }
              ];

              ui = {
                noice.enable = true;
                illuminate.enable = true;
                colorizer.enable = true;
              };

              visuals = {
                indent-blankline.enable = true;
                rainbow-delimiters.enable = true;
              };

              viAlias = true;
              vimAlias = true;
              undoFile.enable = true;

              spellcheck.enable = true;

              binds = {
                whichKey.enable = true;
                cheatsheet.enable = true;
              };

              debugger.nvim-dap = {
                enable = true;
                ui.enable = true;
              };

              treesitter = {
                enable = true;
                indent.enable = true;
              };
              telescope.enable = true;

              lsp = {
                enable = true;
                formatOnSave = true;
                trouble.enable = true;
                inlayHints.enable = true;
                lspkind.enable = true;
              };

              minimap.codewindow.enable = true;

              autocomplete.blink-cmp.enable = true;

              git = {
                enable = true;
                gitsigns.enable = true;
              };

              diagnostics = {
                enable = true;
                config = {
                  virtual_lines.format =
                    nixpkgs.lib.generators.mkLuaInline
                    ''
                      function(diagnostic)
                        return string.format("%s (%s)", diagnostic.message, diagnostic.source)
                      end
                    '';
                  underline = false;
                };
                nvim-lint = {
                  enable = true;
                };
              };

              notes.todo-comments.enable = true;
              statusline.lualine = {
                enable = true;
              };
              languages = {
                enableFormat = true;
                enableTreesitter = true;
                enableExtraDiagnostics = true;
                enableDAP = true;

                go.enable = true;
                markdown = {
                  enable = true;
                  extensions.render-markdown-nvim.enable = true;
                };
                css.enable = true;
                html.enable = true;
                yaml.enable = true;
                zig.enable = true;

                nix = {
                  enable = true;
                  lsp.servers = ["nixd"];
                };

                csharp = {
                  enable = true;
                  lsp.servers = ["omnisharp"];
                };
              };
            };
          }
        ];
      };
  in {
    packages = forAllSystems (system: {
      default = (mkNeovimConfig {} system).neovim;
    });
  };
}
