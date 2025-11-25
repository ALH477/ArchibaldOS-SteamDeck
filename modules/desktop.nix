# modules/desktop.nix
{ config, pkgs, ... }:
lib.mkIf (!config.archibaldOS.enableHeadless) (
let
  basicPackages = with pkgs; [
    vim kitty wireplumber cava playerctl
    jetbrains-mono noto-fonts-emoji
  ];
in {
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.defaultSession = "plasma";

  services.displayManager.sddm.settings = {
    General.Background = "/usr/share/wallpapers/ArchibaldOS/demod-wallpaper.jpg";
  };

  environment.systemPackages = basicPackages;
}
)
