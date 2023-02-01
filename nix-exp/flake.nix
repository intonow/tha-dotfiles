# flake.nix from hyprland combined with the nixos wiki

# idk what i am doing rn so this needs further investigation


{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
  };

  outputs = { self, nixpkgs, hyprland, ...}: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      # ...
      system = "x86_64-linux";
      modules = [
        hyprland.nixosModules.default
        {programs.hyprland.enable = true;}
        # the configuration.nix
        ./configuration.nix
      ];
    };
  };
}

/*
{
  outputs = { self, nixpkgs }: {
    # replace 'joes-desktop' with your hostname here.
    nixosConfigurations.joes-desktop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
    };
  };
}
*/
