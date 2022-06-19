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
  inputs.deno2nix.url = "https://github.com/SnO2WMaN/deno2nix";
  inputs.devshell.url = "github:numtide/devshell";

  outputs = {
    deno2nix,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          devshell.overlay
          deno2nix.overlay
        ];
      };
    in {
      packages.executable = pkgs.deno2nix.mkExecutable {
        name = "example";
        version = "0.1.0";
        src = self;
        lockfile = ./lock.json;
        importmap = ./import_map.json;
        entrypoint = ./mod.ts;
      };
    });
}
```

### `deno2nix.mkExecutable`

#### Args

```nix
 {
    name,
    version,
    src,
    entrypoint,
    lockfile,
    importmap ? null,
    denoFlags ? [],
}
```

- `importMap = ./import_map.json`
- `denoFlags = ["--allow-net" true]`

## Thanks

- [esselius/nix-deno](https://github.com/esselius/nix-deno)
  - Original
- [brecert/nix-deno](https://github.com/brecert/nix-deno)
  - Fork of [esselius/nix-deno](https://github.com/esselius/nix-deno)
