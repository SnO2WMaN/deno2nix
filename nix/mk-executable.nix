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
  output ? pname,
  entrypoint,
  lockfile,
  config,
  allow ? {},
  additionalDenoFlags ? "",
} @ inputs: let
  inherit (builtins) isString;
  inherit (lib) importJSON concatStringsSep;
  inherit (deno2nix.internal) mkDepsLink findImportMap;

  allowflag = flag: (
    if (allow ? flag) && allow."${flag}"
    then ["--allow-${flag}"]
    else []
  );

  importMap = findImportMap {
    inherit (inputs) src config importMap;
  };

  compileCmd = concatStringsSep " " (
    [
      "deno compile --cached-only"
      "--lock=${lockfile}"
      "--output=${output}"
      # "--config=${config}"
    ]
    ++ (
      if (isString importMap)
      then ["--import-map=${importMap}"]
      else []
    )
    ++ (allowflag "all")
    ++ (allowflag "env")
    ++ (allowflag "ffi")
    ++ (allowflag "hrtime")
    ++ (allowflag "net")
    ++ (allowflag "read")
    ++ (allowflag "run")
    ++ (allowflag "sys")
    ++ (allowflag "write")
    ++ [additionalDenoFlags]
    ++ ["${entrypoint}"]
  );
in
  stdenv.mkDerivation {
    inherit pname version src;
    dontFixup = true;

    buildInputs = with pkgs; [deno jq];
    buildPhase = ''
      export DENO_DIR="/tmp/deno2nix"
      mkdir -p $DENO_DIR
      ln -s "${mkDepsLink (src + "/${lockfile}")}" $(deno info --json | jq -r .modulesCache)
      ${compileCmd}
    '';
    installPhase = ''
      mkdir -p $out/bin
      cp "${output}" "$out/bin/"
    '';
  }
