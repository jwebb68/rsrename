#see: https://perlpimp.net/blog/crane-dual-workflow-nix-rust/
{
  description = "Build a cargo project without extra checks";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      crane,
      flake-utils,
      rust-overlay,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        #pkgs = nixpkgs.legacyPackages.${system};
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };

        #craneLib = crane.mkLib pkgs;
        craneLib = (crane.mkLib pkgs).overrideToolchain (
          p:
          p.rust-bin.stable.latest.default.override {
            extensions = [
                "rust-src"
                "clippy"
                "rustfmt"
            ];
            #targets = [ "wasm32-wasip1" ];
          }
        );

        # rustToolchain = pkgs.rust-bin.stable.latest.default.override {
        #     extensions = [
        #         "rust-src" # for rust-analyser
        #         "clippy"
        #         "rustfmt"
        #     ];
        #     #targets = [ "wasm32-wasip1" ];
        # };
        # craneLib = (crane.mkLib pkgs).overrideToolchain rustToolchain;

        # Common arguments can be set here to avoid repeating them later
        # Note: changes here will rebuild all dependency crates
        commonArgs = {
          src = craneLib.cleanCargoSource ./.;
          strictDeps = true;

          buildInputs = [
            # Add additional build inputs here
            # pkgs.libxkbcommon
            # pkgs.fontconfig
            # pkgs.vulkan-loader
            # pkgs.wayland
          ]
          ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
            # Additional darwin specific inputs can be set here
            pkgs.libiconv
          ];

          runtimeDependencies = pkgs.lib.optionals pkgs.stdenv.hostPlatform.isLinux [
            # pkgs.vulkan-loader
            # pkgs.wayland
          ];

          autoPatchelfIgnoreMissingDeps = ["libgcc_s.so.1"];

          nativeBuildInputs = [
            pkgs.pkg-config
            pkgs.autoPatchelfHook
          ];

          meta = {
            description = "Rust based file renamer";
            homepage = "";
            license = nixpkgs.lib.licenses.asl20;
            #platforms = [ "x86_64-linux" ];
          };

        };

        my-crate = craneLib.buildPackage (
          commonArgs
          // {
            cargoArtifacts = craneLib.buildDepsOnly commonArgs;

            # Additional environment variables or build phases/hooks can be set
            # here *without* rebuilding all dependency crates
          }
        );
      in
      {
        checks = {
          inherit my-crate;
        };

        packages.default = my-crate;

        apps.default = flake-utils.lib.mkApp {
          drv = my-crate;
        };

        devShells.default = craneLib.devShell {
          # Inherit inputs from checks.
          checks = self.checks.${system};

          # Additional dev-shell environment variables can be set directly
          # MY_CUSTOM_DEVELOPMENT_VAR = "something else";
          #LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
          #    wayland
          #    vulkan-loader
          #    # any other libraries that need to be dynamically linked to
          #]);
          # MY_CUSTOM_VAR = "some value";
          # (non-nix) cargo build: app uses system libs
          # (non-nix) cargo build --release: app uses system libs
          # (nix, dev) cargo build: must have rpath set for wayland+vulkan loader (CARGO_BUILD_RUSTFLAGS)
          # (nix, dev) cargo build --release: must have rpath set for wayland+vulkan loader (CARGO_BUILD_RUSTFLAGS)
          # (ix, non-dev): nix build : must put rpath to wayland+vulkan loader for current sys generation. (autoPatchelfHook)

          # buildInputs are added as rpaths, but the deps needed for dlopen libs are not
          # so use runtimeDependencies to add them (so using sasme var as autoPatchelfHook)
          # https://stackoverflow.com/questions/40602708/linking-rust-application-with-a-dynamic-library-not-in-the-runtime-linker-search
          CARGO_BUILD_RUSTFLAGS="-C link-args=-Wl,-rpath,${pkgs.lib.makeLibraryPath commonArgs.runtimeDependencies}";

          # Extra  (build) inputs can be added here; cargo and rustc are provided by default.
          packages = [
            # pkgs.ripgrep
            pkgs.rust-analyzer
            pkgs.taplo # toml fomatting
          ];
        };
      }
    );
}


# {
#   inputs = {
#     flake-utils.url = "github:numtide/flake-utils";
#     naersk = {
#       url = "github:nix-community/naersk";
#       inputs.nixpkgs.follows = "nixpkgs";
#     };
#     nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#   };

#   outputs = { flake-utils, naersk, nixpkgs, ... }:
#     flake-utils.lib.eachDefaultSystem (system:
#       let
#         pkgs = (import nixpkgs) { inherit system; };

#         naersk' = pkgs.callPackage naersk { };

#       in {
#         # For `nix build` & `nix run`:
#         packages.default = naersk'.buildPackage {
#           src = ./.;

#           meta = {
#             description = "Rust based file renamer";
#             homepage = "";
#             license = nixpkgs.lib.licenses.asl20;
#             #platforms = [ "x86_64-linux" ];
#           };

#         };

#         # For `nix develop`:
#         devShell = pkgs.mkShell {
#           nativeBuildInputs = with pkgs; [
#             rustc
#             cargo
#             clippy
#             #pkgs.rls
#             rust-analyzer
#             taplo # toml fomatting
#           ];
#         };
#       });
# }
