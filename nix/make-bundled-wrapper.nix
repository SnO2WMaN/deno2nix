{pkgs, ...}: {name, ...} @ args: let
  bundled = (pkgs.callPackage ./make-bundled.nix {}) args;
in
  pkgs.writeShellScriptBin
  "${name}"
  "${pkgs.deno}/bin/deno run ${bundled}/dist/bundled.js"
