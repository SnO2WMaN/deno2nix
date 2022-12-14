final: prev: {
  deno2nix = {
    mkBundled = final.callPackage ./make-bundled.nix {};
    mkBundledWrapper = final.callPackage ./make-bundled-wrapper.nix {};
    mkExecutable = final.callPackage ./make-executable.nix {};

    internal = final.callPackage ./internal {};
  };
}
