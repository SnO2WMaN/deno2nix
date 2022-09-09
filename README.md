# deno2nix

[Nix](https://nixos.org/) support for [Deno](https://deno.land)

## Usage

- lockfile -> `./lock.json`
- import map -> `./import_map.json`
- entrypoint -> `./mod.ts`

### Update `lock.json` for caching

```bash
deno cache --import-map=./import_map.json --lock lock.json --lock-write ./mod.ts
```

### Setup for nix flake (example)

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
          deno2nix.overlay
        ];
      };
    in {
      packages.executable = deno2nix.mkExecutable {
        pname = "example-executable";
        version = "0.1.2";

        src = ./.;
        lockfile = ./lock.json;

        output = "example";
        entrypoint = "./mod.ts";
        importMap = "./import_map.json";
      };
    });
}
```

### `deno2nix.mkExecutable`

#### Args

```nix
{
  pname,
  version,
  src,
  lockfile,
  output ? pname, # generate binary name
  entrypoint,
  importMap ? null, # ex. "./import_map.json" to $src/${importMap}
  additionalDenoFlags ? "", # ex. "--allow-net"
}
```

## Thanks

- [esselius/nix-deno](https://github.com/esselius/nix-deno)
  - Original
- [brecert/nix-deno](https://github.com/brecert/nix-deno)
  - Fork of [esselius/nix-deno](https://github.com/esselius/nix-deno)
