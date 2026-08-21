# pkgs/apple-color-emoji/default.nix
# ── Apple Color Emoji repackaged as CBDT/CBLC TTF for Linux ──────────────
# Pre-built release fetched from github:samuelngs/apple-emoji-ttf.
# To bump: update the URL tag in `src.url`, then update the hash.
{ lib, stdenv, fetchurl }:

stdenv.mkDerivation {
  pname = "apple-color-emoji";
  version = "macos-26-20260722";

  src = fetchurl {
    url = "https://github.com/samuelngs/apple-emoji-ttf/releases/download/macos-26-20260722-484daf4e/AppleColorEmoji-Linux.ttf";
    hash = "sha256-43x69iZaxKCvbVe8ZehhCad22ZZug0MzRVf2PaSCUW8=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/share/fonts/truetype/AppleColorEmoji.ttf
    runHook postInstall
  '';

  meta = with lib; {
    description = "Apple Color Emoji repackaged as CBDT/CBLC TTF for Linux";
    longDescription = ''
      Pre-built release from github:samuelngs/apple-emoji-ttf. The build
      tooling is Apache-2.0 but the emoji glyphs themselves are Apple Inc.'s
      copyrighted assets, so this is treated as unfree-redistributable.
    '';
    homepage = "https://github.com/samuelngs/apple-emoji-ttf";
    license = licenses.unfreeRedistributable;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
