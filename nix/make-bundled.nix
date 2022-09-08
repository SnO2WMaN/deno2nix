{
  pkgs,
  stdenv,
  deno2nix,
  lib,
  ...
}: {
  name,
  version,
  src,
  entrypoint,
  lockfile,
  importMap ? null,
  denoFlags ? [],
}: let
  inherit (deno2nix.internal) mkDepsLink;
in
  stdenv.mkDerivation {
    inherit name version entrypoint;
    denoFlags =
      denoFlags
      ++ (
        if importMap != null
        then ["--import-map" importMap]
        else []
      );

    src = lib.cleanSourceWith {
      inherit src;
      filter = path: type: (baseNameOf path != "bundled.js");
    };
    buildInputs = with pkgs; [
      deno
      jq
    ];

    buildPhase = ''
      export DENO_DIR=`mktemp -d`
      ln -s "${mkDepsLink lockfile}" $(deno info --json | jq -r .modulesCache)

      deno bundle $denoFlags $entrypoint bundled.js
    '';
    installPhase = ''
      mkdir -p $out/dist
      install -t $out/dist bundled.js
    '';
  }
