{
  description = "Nixbom is a tool intended to generate Software Bill of Materials (SBOM) based on Nix expressions and derivations.";

  inputs.crane.url = "github:ipetkov/crane";
  inputs.crane.inputs.nixpkgs.follows = "nixpkgs";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  inputs.rust-overlay.url = "github:oxalica/rust-overlay";
  inputs.rust-overlay.inputs.flake-utils.follows = "flake-utils";
  inputs.rust-overlay.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { self, nixpkgs, crane, rust-overlay, flake-utils}:
    flake-utils.lib.simpleFlake {
      inherit self nixpkgs;
      name = "nixbom";
      systems = flake-utils.lib.allSystems;
      preOverlays = [ rust-overlay.overlay ];
      overlay = final: prev: {
        nixbom = rec {
          nixbom = with final; with pkgs; let 
            buildInputs = [
              rust-bin.stable.latest.minimal
            ];
          in crane.lib.${final.system}.buildPackage {
            pname = "nixbom";
            version = "1.0";
            src = self;
            inherit buildInputs;
            cargoArtifacts = crane.lib.${final.system}.buildDepsOnly { 
              src = self; 
              inherit buildInputs;
            };
          };
          
          defaultPackage = nixbom;
        };
      };
    };
}
