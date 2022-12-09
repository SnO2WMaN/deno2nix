{
  pkgs,
  lib,
  linkFarm,
  writeText,
  ...
}: let
  inherit (builtins) split elemAt fetchurl toJSON hashString baseNameOf;
  inherit (lib) flatten mapAttrsToList importJSON;
  inherit (lib.strings) sanitizeDerivationName;

  # https://deno.land/std@0.118.0/fmt/colors.ts
  #
  # 0. "https"
  # 1. "deno.land"
  # 2. "/std@0.118.0/fmt/colors.ts"
  urlPart = url: elemAt (flatten (split "://([a-z0-9\.]*)" url));

  # https://deno.land/std@0.118.0/fmt/colors.ts
  #
  # https/deno.land/<sha256 "/std@0.118.0/fmt/colors.ts">
  artifactPath = url: let up = urlPart url; in "${up 0}/${up 1}/${hashString "sha256" (up 2)}";
in {
  mkDepsLink = lockfile: (
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
  );
}
