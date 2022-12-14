{lib, ...}: let
  inherit (lib) importJSON;
in
  {
    src,
    config,
    importMap,
  }:
  # TODO: if importMap is exists, fallback
  ((importJSON (src + "/${config}")).importMap)
