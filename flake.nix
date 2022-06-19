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
    rec {
      overlays.default = import ./overlay.nix;
      overlay = overlays.default;
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
          ];
        };
      in rec {
        lib = {
          inherit (import ./nix {inherit pkgs;}) mkDepsLink mkBundledWrapper mkExecutable;
        };

        packages.bundled = lib.mkBundled {
          name = "example";
          version = "0.1.0";
          src = self;
          lockfile = ./lock.json;
          importMap = ./import_map.json;
          entrypoint = ./mod.ts;
        };
        packages.wrapper = lib.mkBundledWrapper {
          name = "example";
          version = "0.1.0";
          src = self;
          lockfile = ./lock.json;
          importMap = ./import_map.json;
          entrypoint = ./mod.ts;
        };
        packages.executable = lib.mkExecutable {
          name = "example";
          version = "0.1.0";
          src = self;
          lockfile = ./lock.json;
          importMap = ./import_map.json;
          entrypoint = ./mod.ts;
        };
        packages.default = packages.executable;

        defaultPackage = packages.default;

        apps.default = {
          type = "app";
          program = "${defaultPackage}/bin/example";
        };

        devShell = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };
      }
    );
}
