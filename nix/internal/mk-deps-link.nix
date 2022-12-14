{
  lib,
  linkFarm,
  writeText,
  deno2nix,
  ...
}: let
  inherit (builtins) split elemAt fetchurl toJSON hashString baseNameOf;
  inherit (lib) flatten mapAttrsToList importJSON;
  inherit (lib.strings) sanitizeDerivationName;
  inherit (deno2nix.internal) artifactPath;
in
  lockfile: (
    linkFarm "deps" (flatten (
      mapAttrsToList
      (
        url: sha256: let
        in [
          {
            name = artifactPath url;
            path = fetchurl {
              inherit url sha256;
              name = sanitizeDerivationName (baseNameOf url);
            };
          }
          {
            name = artifactPath url + ".metadata.json";
            path = writeText "metadata.json" (toJSON {
              inherit url;
              headers = {};
            });
          }
        ]
      )
      (importJSON lockfile).remote
    ))
  )
