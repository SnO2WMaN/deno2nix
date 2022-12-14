{
  pkgs,
  lib,
  stdenv,
  deno2nix,
  ...
}: {
  pname,
  version,
  src,
  output ? "${pname}.bundled.js",
  outPath ? "dist",
  entrypoint,
  lockfile,
  minify ? false,
  additionalDenoFlags ? "",
}: let
  inherit (builtins) isString;
  inherit (lib.strings) concatStringsSep;
  inherit (deno2nix.internal) mkDepsLink;

  bundleCmd = concatStringsSep " " (
    [
      "deno bundle"
      "--lock=${lockfile}"
      # "--config=${config}"
    ]
    ++ [additionalDenoFlags]
    ++ [
      "${entrypoint}"
      "${output}"
    ]
  );
in
  stdenv.mkDerivation {
    inherit pname version entrypoint src;
    buildInputs = with pkgs; [deno jq nodePackages.uglify-js];

    buildPhase = ''
      export DENO_DIR="/tmp/deno2nix"
      mkdir -p $DENO_DIR
      ln -s "${mkDepsLink (src + "/${lockfile}")}" $(deno info --json | jq -r .modulesCache)
      ${bundleCmd}
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
