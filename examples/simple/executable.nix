{deno2nix}:
deno2nix.mkExecutable {
  pname = "simple-executable";
  version = "0.1.0";

  src = ./.;
  bin = "simple";

  entrypoint = "./mod.ts";
  lockfile = "./deno.lock";
  config = "./deno.jsonc";

  allow = {
    all = true;
  };
}
