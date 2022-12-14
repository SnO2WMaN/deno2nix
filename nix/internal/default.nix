{pkgs, ...}: {
  urlPart = pkgs.callPackage ./url-part.nix {};
  artifactPath = pkgs.callPackage ./artifact-path.nix {};
  mkDepsLink = pkgs.callPackage ./mk-deps-link.nix {};
}
