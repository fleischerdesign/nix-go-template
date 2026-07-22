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
    {
      templates.default = {
        path = ./.;
        description = "A reproducible Go development environment with modern tooling";
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.go
            pkgs.gopls
            pkgs.delve
            pkgs.golangci-lint
          ];
          shellHook = ''
            echo "Entering Go development environment..."
            echo "Tools: go, gopls, delve, golangci-lint"
          '';
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
