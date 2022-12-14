{deno2nix}:
deno2nix.mkBundled {
  pname = "simple-bundled";
  version = "0.1.0";

  src = ./.;
  output = "bundled.js";

  entrypoint = "./mod.ts";
  lockfile = "./deno.lock";
}
