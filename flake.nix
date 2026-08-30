{
  description = "A reproducible Go development environment with modern tooling.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    let
      # Granular builder helper for consumer flakes (Way A)
      mkGoShell =
        {
          pkgs,
          goPackage ? pkgs.go,
          extraPackages ? [ ],
          env ? { },
          shellHook ? "",
        }:
        let
          baseShell = pkgs.mkShell {
            packages =
              [
                goPackage
                pkgs.gopls
                pkgs.delve
                pkgs.golangci-lint
                pkgs.gotools
              ]
              ++ extraPackages;
            shellHook = ''
              echo "Entering Go development environment..."
              echo "Tools: go, gopls, delve, golangci-lint, gotools"
            '';
          };
        in
        baseShell.overrideAttrs (oldAttrs: {
          env = oldAttrs.env or { } // env;
          shellHook = (oldAttrs.shellHook or "") + "\n" + shellHook;
        });
    in
    {
      # Granular Library helper functions for consumer flakes
      lib = {
        inherit mkGoShell;
      };

      # Scaffolding templates for 'nix flake init' (Way B)
      templates = {
        default = {
          path = ./.;
          description = "A reproducible Go development environment with modern tooling";
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        defaultShell = mkGoShell { inherit pkgs; };
      in
      {
        devShells = {
          default = defaultShell;
        };

        checks = {
          default = defaultShell;
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = pkgs.writeShellScriptBin "go-env-info" ''
              echo "=== Go Nix Development Environment ==="
              ${pkgs.go}/bin/go version
            '';
          };
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
