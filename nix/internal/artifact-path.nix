{
  lib,
  deno2nix,
  ...
}: let
  inherit (builtins) hashString;
  inherit (deno2nix.internal) urlPart;
in
  # input: https://deno.land/std@0.118.0/fmt/colors.ts
  #
  # output: https/deno.land/<sha256 "/std@0.118.0/fmt/colors.ts">
  url: let
    up = urlPart url;
  in "${up 0}/${up 1}/${hashString "sha256" (up 2)}"
