{
  description = "Quickshell Island";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    homeManagerModules = {
      default = import ./home-manager.nix;
    };
  };
}
