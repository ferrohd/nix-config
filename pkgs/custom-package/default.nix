# pkgs/custom-package/default.nix
# ── Template for a custom package ────────────────────────────────────────
# This is an example/reference. To use it, copy this directory, rename, fill
# in real values, and wire it into overlays/default.nix as a callPackage entry.
{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "my-custom-tool";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "YOUR_USER";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  meta = with lib; {
    description = "My custom tool packaged for Nix";
    homepage = "https://github.com/YOUR_USER/${pname}";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
