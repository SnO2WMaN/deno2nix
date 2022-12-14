# deno2nix

[Nix](https://nixos.org/) support for [Deno](https://deno.land)

## Usage

There is a [sample project](/examples/simple).

```nix
{
  inputs.deno2nix.url = "github:SnO2WMaN/deno2nix";
  inputs.devshell.url = "github:numtide/devshell";
 
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      inherit (pkgs) deno2nix;
      pkgs = import nixpkgs {
        inherit system;
        overlays = with inputs; [
          devshell.overlay
          deno2nix.overlays.default
        ];
      };
    in {
      packages.executable = deno2nix.mkExecutable {
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
      });
}
```

## Thanks

- [esselius/nix-deno](https://github.com/esselius/nix-deno)
  - Original
- [brecert/nix-deno](https://github.com/brecert/nix-deno)
  - Fork of [esselius/nix-deno](https://github.com/esselius/nix-deno)
