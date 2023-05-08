# -*- mode: nix; indent-tabs-mode: nil; tab-width: 2 -*-
{ stdenv
, lib
, rustPlatform
}:

rustPlatform.buildRustPackage rec {
  pname = "rsrename";
  version = "0.1.0";

  src = ./.;

  #cargoSha256 = "0000000000000000000000000000000000000000000000000000";
  cargoSha256 = "sha256-VzBJpX4JRSoRf1ZmicmFsJWSM8d021q/9F1Ke5rzMoY=";

  buildInputs = [
  ];

  meta = {
    description = "Rust based file renamer";
    homepage = "";
    license = lib.licenses.asl20;
    #platforms = [ "x86_64-linux" ];
  };
}
