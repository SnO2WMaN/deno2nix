{
  pkgs,
  lib ? pkgs.lib,
  ...
}: let
  inherit (builtins) hashString split elemAt fetchurl toJSON;
  inherit (pkgs) linkFarm writeText;
  inherit (lib) flatten mapAttrsToList importJSON;
in rec {
  urlPart = url: elemAt (flatten (split "://([a-z0-9\.]*)" url));
  artifactPath = url: "${urlPart url 0}/${urlPart url 1}/${hashString "sha256" (urlPart url 2)}";

  mkDepsLink = lockfile: (
    linkFarm "deps" (lib.flatten (
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
    ))
  );
}
