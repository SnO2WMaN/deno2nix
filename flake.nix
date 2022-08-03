{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    ...
  } @ inputs:
    {
      overlays.default = import ./overlay.nix;
      overlay = self.overlays.default;
    }
    // flake-utils.lib.eachSystem [
      "x86_64-linux"
    ]
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            self.overlays.default
          ];
        };
      in {
        packages.bundled = pkgs.deno2nix.mkBundled {
          name = "example";
          version = "0.1.0";
          src = self;
          lockfile = ./lock.json;
          importMap = ./import_map.json;
          entrypoint = ./mod.ts;
        };
        packages.wrapper = pkgs.deno2nix.mkBundledWrapper {
          name = "example";
          version = "0.1.0";
          src = self;
          lockfile = ./lock.json;
          importMap = ./import_map.json;
          entrypoint = ./mod.ts;
        };
        packages.executable = pkgs.deno2nix.mkExecutable {
          name = "example";
          version = "0.1.0";
          src = self;
          lockfile = ./lock.json;
          importMap = ./import_map.json;
          entrypoint = ./mod.ts;
        };
        packages.default = self.packages.${system}.executable;
        defaultPackage = self.packages.${system}.default;

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.executable}/bin/example";
        };

        checks = self.packages.${system};

        devShell = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };
      }
    );
}
