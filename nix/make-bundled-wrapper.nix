{
  pkgs,
  deno,
  deno2nix,
  writeShellScriptBin,
  ...
}: {
  pname,
  bin ? pname,
  output ? "bundled.js",
  ...
} @ args: let
  bundled = deno2nix.mkBundled args;
in
  writeShellScriptBin
  bin
  "${deno}/bin/deno run ${bundled}/dist/${output}"
