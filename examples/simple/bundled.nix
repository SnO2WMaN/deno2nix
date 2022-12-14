{deno2nix}:
deno2nix.mkBundled {
  pname = "simple";
  version = "0.1.0";

  src = ./.;

  entrypoint = "./mod.ts";
  lockfile = "./deno.lock";
  config = "./deno.jsonc";

  allow = {
    all = true;
  };
}
