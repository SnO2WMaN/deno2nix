final: prev: {
  deno2nix = {
    inherit (import ./nix {pkgs = prev;}) mkBundled mkBundledWrapper mkExecutable;
  };
}
