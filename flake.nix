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
    flake-utils.lib.eachSystem
    [
      "x86_64-linux"
    ]
    (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
            (import ./overlay.nix)
          ];
        };
      in rec {
        packages.bundled = pkgs.deno2nix.mkBundled {
          name = "example";
          version = "0.1.0";
          src = self;
          lockfile = ./lock.json;
          importmap = ./import_map.json;
          entrypoint = ./mod.ts;
        };
        packages.wrapper = pkgs.deno2nix.mkBundledWrapper {
          name = "example";
          version = "0.1.0";
          src = self;
          lockfile = ./lock.json;
          importmap = ./import_map.json;
          entrypoint = ./mod.ts;
        };
        packages.executable = pkgs.deno2nix.mkExecutable {
          name = "example";
          version = "0.1.0";
          src = self;
          lockfile = ./lock.json;
          importmap = ./import_map.json;
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
