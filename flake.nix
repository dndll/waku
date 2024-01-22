{
  description = "A flake to build waku";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { 
          inherit system overlays; 
        };
        rustVersion = (pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml);
        rustPlatform = pkgs.makeRustPlatform {
          cargo = rustVersion;
          rustc = rustVersion;
        };
      in {
       devShell = pkgs.mkShell {
          LD_LIBRARY_PATH = "${pkgs.libclang.lib}/lib:/usr/local/lib";

          nativeBuildInputs = with pkgs; [ 
            bashInteractive
            taplo
            cmake
            openssl
            pkg-config
            clang-tools
            clang
            protobuf
            pkg-config

            go
          ];
          buildInputs = with pkgs; [ 
              (rustVersion.override { extensions = [ "rust-src" ]; }) 
          ];
          
        };
  });
}
