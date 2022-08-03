final: prev: {
  deno2nix = {
    mkBundled = final.callPackage ./nix/make-bundled.nix {};
    mkBundledWrapper = final.callPackage ./nix/make-bundled-wrapper.nix {};
    mkExecutable = final.callPackage ./nix/make-executable.nix {};
  };
}
