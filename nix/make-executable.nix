{pkgs, ...}: {
  name,
  version,
  src,
  entrypoint,
  lockfile,
  importMap ? null,
  denoFlags ? [],
}: let
  inherit (pkgs.callPackage ./utils.nix {}) mkDepsLink;
in
  pkgs.stdenv.mkDerivation {
    inherit src name entrypoint;
    denoFlags =
      denoFlags
      ++ ["--lock" lockfile]
      ++ ["--cached-only"]
      ++ ["--output" name]
      ++ (
        if importMap != null
        then ["--import-map" importMap]
        else []
      );
    buildInputs = with pkgs; [
      deno
      jq
    ];
    fixupPhase = ":";

    buildPhase = ''
      export DENO_DIR=`mktemp -d`
      ln -s "${mkDepsLink lockfile}" $(deno info --json | jq -r .modulesCache)

      deno compile $denoFlags "$entrypoint"
    '';
    installPhase = ''
      mkdir -p $out/bin
      mv "$name" "$out/bin/"
    '';
  }
