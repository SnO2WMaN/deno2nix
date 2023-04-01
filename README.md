# deno2nix

[Nix](https://nixos.org/) support for [Deno](https://deno.land)

## Usage

There is a [sample project](/examples/simple).

```nix
{
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.deno2nix.url = "github:SnO2WMaN/deno2nix";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    deno2nix,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [deno2nix.overlays.default];
      };
    in {
      packages.executable = pkgs.deno2nix.mkExecutable {
        pname = "simple-executable";
        version = "0.1.0";

        src = ./.;
        bin = "simple";

        entrypoint = "./mod.ts";
        lockfile = "./deno.lock";
        config = "./deno.jsonc";

        allow = {
          all = true;
        };
      };
    });
}
```

## Thanks

- [esselius/nix-deno](https://github.com/esselius/nix-deno)
  - Original
- [brecert/nix-deno](https://github.com/brecert/nix-deno)
  - Fork of [esselius/nix-deno](https://github.com/esselius/nix-deno)
