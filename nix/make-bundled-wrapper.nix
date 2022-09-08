{
  pkgs,
  deno,
  deno2nix,
  writeShellScriptBin,
  ...
}: {name, ...} @ args: let
  bundled = deno2nix.mkBundled args;
in
  writeShellScriptBin
  "${name}"
  "${deno}/bin/deno run ${bundled}/dist/bundled.js"
