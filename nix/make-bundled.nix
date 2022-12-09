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
  outPath ? "dist",
  minify ? false,
  entrypoint,
  importMap ? null,
  additionalDenoFlags ? "",
}: let
  inherit (deno2nix.internal) mkDepsLink;
in
  stdenv.mkDerivation {
    inherit pname version entrypoint src;
    buildInputs = with pkgs; [ deno jq nodePackages.uglify-js ];

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

      ${
        if minify
        then ''
          mv ${output} ${output}-non-min
          uglifyjs ${output}-non-min -c -m > ${output}
        ''
        else ""
      }
    '';
    installPhase = ''
      mkdir -p $out/${outPath}
      install -t $out/${outPath} "${output}"
    '';
  }
