{
  pkgs,
  stdenv,
  deno2nix,
  ...
}: {
  pname,
  version,
  src,
  lockfile,
  output ? pname,
  entrypoint,
  importMap ? null,
  additionalDenoFlags ? "",
}: let
  inherit (deno2nix.internal) mkDepsLink;
in
  stdenv.mkDerivation {
    inherit pname version src;
    dontFixup = true;

    buildInputs = with pkgs; [deno jq];
    buildPhase = ''
      export DENO_DIR="/tmp/deno2nix"
      mkdir -p $DENO_DIR
      ln -s "${mkDepsLink lockfile}" $(deno info --json | jq -r .modulesCache)

      deno compile \
        --cached-only \
        --lock="${lockfile}" \
        --output="${output}" \
        ${
        if importMap != null
        then "--import-map=\"$src/${importMap}\""
        else ""
      } \
        ${additionalDenoFlags} \
        "$src/${entrypoint}"
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp "${output}" "$out/bin/"
    '';
  }
