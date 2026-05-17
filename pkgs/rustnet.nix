{ lib, rustPlatform, src, pkg-config, libpcap, elfutils, zlib, clang }:

rustPlatform.buildRustPackage rec {
  pname = "rustnet";
  version = "1.3.0";

  inherit src;

  cargoLock.lockFile = "${src}/Cargo.lock";

  nativeBuildInputs = [ pkg-config clang ];

  buildInputs = [ libpcap elfutils zlib ];

  doCheck = false;

  preConfigure = ''
    export CLANG_PATH="${clang}/bin/clang"
  '';

  meta = with lib; {
    description = "Per-process network monitoring for your terminal with deep packet inspection";
    homepage = "https://github.com/domcyrus/rustnet";
    changelog = "https://github.com/domcyrus/rustnet/releases/tag/v${version}";
    license = licenses.asl20;
    mainProgram = "rustnet";
    platforms = platforms.linux;
  };
}
