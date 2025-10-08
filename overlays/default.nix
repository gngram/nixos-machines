{ pkgs, config, lib, ... }:

let
  myOverlay = import ./overlays.nix;
in
{
  nixpkgs.overlays = [
    myOverlay
  ] ++ (config.nixpkgs.overlays or []);
}
