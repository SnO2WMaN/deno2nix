final: prev: {
  deno2nix = {
    mkBundled = final.callPackage ./mk-bundled.nix {};
    mkBundledWrapper = final.callPackage ./make-bundled-wrapper.nix {};
    mkExecutable = final.callPackage ./mk-executable.nix {};

    internal = final.callPackage ./internal {};
  };
}
