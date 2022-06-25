{
  pkgs,
  lib ? pkgs.lib,
}: let
  inherit (builtins) readFile hashString split elemAt fetchurl toJSON baseNameOf;
  inherit (pkgs) linkFarm writeText stdenv writeShellScriptBin;
  inherit (lib) flatten mapAttrsToList importJSON cleanSourceWith;

  urlPart = url: elemAt (flatten (split "://([a-z0-9\.]*)" url));
  artifactPath = url: "${urlPart url 0}/${urlPart url 1}/${hashString "sha256" (urlPart url 2)}";

  mkDepsLink = lockfile:
    linkFarm "deps" (flatten (
      mapAttrsToList
      (
        url: sha256: [
          {
            name = artifactPath url;
            path = fetchurl {inherit url sha256;};
          }
          {
            name = (artifactPath url) + ".metadata.json";
            path = writeText "metadata.json" (toJSON {
              inherit url;
              headers = {};
            });
          }
        ]
      )
      (importJSON lockfile)
    ));
in rec {
  mkBundled = {
    name,
    version,
    src,
    entrypoint,
    lockfile,
    importMap ? null,
    denoFlags ? [],
  }:
    stdenv.mkDerivation {
      inherit name version entrypoint;
      denoFlags =
        denoFlags
        ++ (
          if importMap != null
          then ["--import-map" importMap]
          else []
        );

      src = cleanSourceWith {
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
    };
  mkBundledWrapper = {
    name,
    entrypoint,
    ...
  } @ args: let
    bundled = mkBundled args;
  in
    writeShellScriptBin
    "${name}"
    "${pkgs.deno}/bin/deno run ${bundled}/dist/bundled.js";

  mkExecutable = {
    name,
    version,
    src,
    entrypoint,
    lockfile,
    importMap ? null,
    denoFlags ? [],
  }:
    stdenv.mkDerivation {
      inherit src name entrypoint;
      denoFlags =
        denoFlags
        ++ ["--lock" "${src}/${lockfile}"]
        ++ ["--cached-only"]
        ++ ["--output" name]
        ++ (
          if importMap != null
          then ["--import-map" "${src}/${importMap}"]
          else []
        );
      buildInputs = with pkgs; [
        deno
        jq
      ];
      fixupPhase = ":";

      buildPhase = ''
        export DENO_DIR=`mktemp -d`
        ln -s "${mkDepsLink "${src}/${lockfile}"}" $(deno info --json | jq -r .modulesCache)
        ls $(dirname $src/$entrypoint)

        deno compile $denoFlags "$entrypoint"
      '';
      installPhase = ''
        mkdir -p $out/bin
        mv "$name" "$out/bin/"
      '';
    };
}
