{lib, ...}: let
  inherit (builtins) split elemAt;
  inherit (lib) flatten;
in
  # input: https://deno.land/std@0.118.0/fmt/colors.ts
  #
  # output:
  # 0. "https"
  # 1. "deno.land"
  # 2. "/std@0.118.0/fmt/colors.ts"
  url: elemAt (flatten (split "://([a-z0-9\.]*)" url))
