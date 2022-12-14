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
      overlay = self.overlays.default;
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
          "simple/executable" = pkgs.callPackage ./examples/simple/executable.nix {};
        };
        apps = {
          "simple/executable" = flake-utils.lib.mkApp {
            drv = self.packages.${system}."simple/executable";
            name = "simple";
          };
        };

        /*
        packages.bundled = deno2nix.mkBundled {
          pname = "example-bundled";
          version = "0.1.0";

          src = ./.;
          lockfile = ./lock.json;

          output = "bundled.js";
          entrypoint = "./mod.ts";
          importMap = "./import_map.json";
          minify = true;
        };
        packages.bundled-wrapper = deno2nix.mkBundledWrapper {
          pname = "example-bundled-wrapper";
          version = "0.1.0";

          src = ./.;
          lockfile = ./lock.json;

          output = "bundled.js";
          entrypoint = "./mod.ts";
          importMap = "./import_map.json";
        };
        packages.executable = deno2nix.mkExecutable {
          pname = "example-executable";
          version = "0.1.2";

          src = ./.;
          lockfile = ./lock.json;

          output = "example";
          entrypoint = "./mod.ts";
          importMap = "./import_map.json";
        };
        packages.default = self.packages.${system}.executable;
        defaultPackage = self.packages.${system}.default;

        apps.bundled-wrapper = flake-utils.lib.mkApp {drv = self.packages.${system}.bundled-wrapper;};
        apps.executable = flake-utils.lib.mkApp {drv = self.packages.${system}.executable;};
        apps.default = self.apps.${system}.executable;

        checks = self.packages.${system};
        */

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
