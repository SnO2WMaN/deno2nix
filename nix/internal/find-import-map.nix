{lib, ...}: let
  inherit (lib) importJSON;
in
  {
    src,
    config,
    importMap,
  }: ((importJSON (src + "/${config}")).importMap)
