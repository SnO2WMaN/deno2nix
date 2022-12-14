{
  # main
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  # dev
  inputs = {
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    {
      overlays.default = import ./nix/overlay.nix;
    }
    // flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ]
    (
      system: let
        inherit (pkgs) deno2nix;
        pkgs = import nixpkgs {
          inherit system;
          overlays = with inputs; [
            self.overlays.default
            devshell.overlay
          ];
        };
      in {
        /*
        TODO: It can't but I don't why
        packages = flake-utils.lib.flattenTree {
           simple = {
             deps-link = pkgs.callPackage ./examples/simple/deps-link.nix {};
             executable = pkgs.callPackage ./examples/simple/executable.nix {};
           };
        };
        */
        packages = {
          "simple/deps-link" = pkgs.callPackage ./examples/simple/deps-link.nix {};
          "simple/bundled" = pkgs.callPackage ./examples/simple/bundled.nix {};
          "simple/bundled-wrapper" = pkgs.callPackage ./examples/simple/bundled-wrapper.nix {};
          "simple/executable" = pkgs.callPackage ./examples/simple/executable.nix {};
        };
        apps = {
          "simple/executable" = flake-utils.lib.mkApp {
            drv = self.packages.${system}."simple/executable";
            name = "simple";
          };
          "simple/bundled-wrapper" = flake-utils.lib.mkApp {
            drv = self.packages.${system}."simple/bundled-wrapper";
            name = "simple";
          };
        };

        checks = self.packages.${system};
        devShells.default = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            deno
            treefmt
            taplo-cli
          ];
        };
      }
    );
}
