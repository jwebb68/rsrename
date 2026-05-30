{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { flake-utils, naersk, nixpkgs, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = (import nixpkgs) { inherit system; };

        naersk' = pkgs.callPackage naersk { };

      in {
        # For `nix build` & `nix run`:
        packages.default = naersk'.buildPackage {
          src = ./.;

          meta = {
            description = "Rust based file renamer";
            homepage = "";
            license = nixpkgs.lib.licenses.asl20;
            #platforms = [ "x86_64-linux" ];
          };

        };

        # For `nix develop`:
        devShell = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            rustc
            cargo
            clippy
            #pkgs.rls
            rust-analyzer
            taplo # toml fomatting
          ];
        };
      });
}
