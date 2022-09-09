{
  pkgs,
  stdenv,
  deno2nix,
  ...
}: {
  pname,
  version,
  src,
  output ? pname,
  entrypoint,
  lockfile,
  importMap ? null,
  denoFlags ? [],
}: let
  inherit (deno2nix.internal) mkDepsLink;
in
  stdenv.mkDerivation {
    inherit pname version src entrypoint;
    denoFlags =
      denoFlags
      ++ ["--lock" lockfile]
      ++ ["--cached-only"]
      ++ ["--output" output]
      ++ (
        if importMap != null
        then ["--import-map" importMap]
        else []
      );
    buildInputs = with pkgs; [deno jq];
    fixupPhase = ":";

    buildPhase = ''
      export DENO_DIR=`mktemp -d`
      ln -s "${mkDepsLink lockfile}" $(deno info --json | jq -r .modulesCache)

      deno compile $denoFlags "$src/${entrypoint}"
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp "${output}" "$out/bin/"
    '';
  }
