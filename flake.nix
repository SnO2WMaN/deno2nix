{
  # main
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  # dev
  inputs = {
    devshell.url = "github:numtide/devshell";
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
      overlay = self.overlays.default;
    }
    // flake-utils.lib.eachSystem [
      "x86_64-linux"
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
        packages.depslink = deno2nix.internal.mkDepsLink ./lock.json;
        packages.bundled = deno2nix.mkBundled {
          name = "example";
          version = "0.1.0";
          src = ./.;
          lockfile = ./lock.json;
          importMap = ./import_map.json;
          entrypoint = ./mod.ts;
        };
        packages.wrapper = deno2nix.mkBundledWrapper {
          name = "example";
          version = "0.1.0";
          src = ./.;
          lockfile = ./lock.json;
          importMap = ./import_map.json;
          entrypoint = ./mod.ts;
        };
        packages.executable = deno2nix.mkExecutable {
          pname = "example";
          version = "0.1.2";

          src = ./.;
          lockfile = ./lock.json;

          output = "example";
          entrypoint = "./mod.ts";
          importMap = ./import_map.json;
        };
        packages.default = self.packages.${system}.executable;
        defaultPackage = self.packages.${system}.default;

        apps.default = flake-utils.lib.mkApp {
          drv = self.packages.${system}.executable;
        };

        checks = self.packages.${system};

        devShells.default = pkgs.devshell.mkShell {
          packages = with pkgs; [
            alejandra
            deno
            treefmt
            taplo-cli
          ];
          commands = [
            {
              package = "treefmt";
              category = "formatters";
            }
          ];
        };
      }
    );
}
