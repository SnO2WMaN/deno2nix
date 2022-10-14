{
  pkgs,
  stdenv,
  deno2nix,
  lib,
  ...
}: {
  pname,
  version,
  src,
  lockfile,
  output ? "bundled.js",
  entrypoint,
  importMap ? null,
  additionalDenoFlags ? "",
}: let
  inherit (deno2nix.internal) mkDepsLink;
in
  stdenv.mkDerivation {
    inherit pname version entrypoint src;
    buildInputs = with pkgs; [deno jq];

    buildPhase = ''
      export DENO_DIR="/tmp/deno2nix"
      mkdir -p $DENO_DIR
      ln -s "${mkDepsLink lockfile}" $(deno info --json | jq -r .modulesCache)

      deno bundle \
        --lock="${lockfile}" \
        ${
        if importMap != null
        then "--import-map=\"$src/${importMap}\""
        else ""
      } \
        ${additionalDenoFlags} \
        "$src/${entrypoint}" \
        "${output}"
    '';
    installPhase = ''
      mkdir -p $out/dist
      install -t $out/dist "${output}"
    '';
  }
