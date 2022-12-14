{deno2nix}:
deno2nix.mkBundledWrapper {
  pname = "simple-bundled";
  version = "0.1.0";

  src = ./.;
  bin = "simple";

  entrypoint = "./mod.ts";
  lockfile = "./deno.lock";
}
