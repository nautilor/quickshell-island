{
  description = "Quickshell Island";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
  };

  outputs = { self, ... }: {
    homeManagerModules.default = import ./home-manager.nix;
    default = self.homeManagerModules.default;
  };
}
