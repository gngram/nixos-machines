{
  description = "My NixOS configurations for multiple platforms";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs }: {
    nixosConfigurations = {
      # Configuration for the first platform
      lenovo-x1 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; 
        modules = [
          ./lenovo-x1/configuration.nix 
        ];
      };

      # Configuration for the second platform
      lab-machine = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux"; 
        modules = [
          ./lab-machine/configuration.nix 
          ./lab-machine/hardware-configuration.nix
        ];
      };
    };
  };
}

