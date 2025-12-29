{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/d603719ec6e294f034936c0d0dc06f689d91b6c3";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = { self, ... }@inputs: (inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems   = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
    perSystem = { pkgs, system, ... }: rec {
      packages.default  = pkgs.callPackage ./iosevka.nix {};
    };
  }) // {
    name         = "customIosevka";
    nixosModules = rec {
      addpkg = { pkgs, ... }: {
        nixpkgs.config = {
          packageOverrides = oldpkgs: let newpkgs = oldpkgs.pkgs; in {
            "${self.name}" = self.packages."${pkgs.stdenv.hostPlatform.system}".default;
          };
        };
      };

      install = { pkgs, ... }: (addpkg { inherit pkgs; }) // {
        fonts.packages = [ pkgs."${self.name}" ];
      };
    };
  };
}
