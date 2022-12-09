{
  description = "Nixbom is a tool intended to generate Software Bill of Materials (SBOM) based on Nix expressions and derivations.";

  inputs.crane.url = "github:ipetkov/crane";
  inputs.crane.inputs.nixpkgs.follows = "nixpkgs";
  inputs.crane.inputs.rust-overlay.follows = "rust-overlay";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, crane, rust-overlay, flake-utils}:
    flake-utils.lib.simpleFlake {
      inherit self nixpkgs;
      name = "nixbom";
      preOverlays = [ rust-overlay.overlays.default ];
      overlay = final: prev: {
        nixbom = rec {
          rust = with final; with pkgs; rust-bin.stable.latest.minimal;
          cranelib = crane.lib."${final.system}".overrideToolchain rust;
          nixbom = with final; with pkgs; let
            buildInputs = [
              rust
            ];
          in cranelib.buildPackage {
            pname = "nixbom";
            version = "1.0";
            src = self;
            inherit buildInputs;
            cargoArtifacts = cranelib.buildDepsOnly {
              src = self;
              inherit buildInputs;
            };
          };

          defaultPackage = nixbom;
        };
      };
    };
}
