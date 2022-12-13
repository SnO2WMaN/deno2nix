{deno2nix}:
deno2nix.mkExecutable {
  pname = "deno2nix-demo-simple";
  version = "0.1.0";

  src = ./.;

  output = "example";

  entrypoint = "./mod.ts";
  lockfile = "./deno.lock";
  config = "./deno.jsonc";

  allow = {
    all = true;
  };
}
