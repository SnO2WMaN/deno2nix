{
  lib,
  deno,
  deno2nix,
  writeShellScriptBin,
  ...
}: {
  pname,
  bin ? pname,
  output ? "${pname}.bundled.js",
  outPath ? "dist",
  ...
} @ args: let
  inherit (lib) filterAttrs;
  bundled = deno2nix.mkBundled (filterAttrs (n: v: n != "bin") args);
in
  writeShellScriptBin
  bin
  "${deno}/bin/deno run ${bundled}/${outPath}/${output}"
