{
  description = "ArchibaldOS Steam Deck: RT Audio-Focused NixOS with Optional Steam UI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    musnix.url = "github:musnix/musnix";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
  };

  outputs = { self, nixpkgs, musnix, disko, jovian }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [ jovian.overlays.default ];
    };

  in {
    nixosConfigurations.archibaldOS-deck = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        jovian.nixosModules.default
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
        musnix.nixosModules.musnix
        ./modules/audio.nix
        ./modules/desktop.nix
        ./modules/users.nix
        ./modules/branding.nix

        ({ config, pkgs, lib, ... }: {
          options.archibaldOS = {
            enableRTAudio = lib.mkEnableOption "Enable real-time audio optimizations" // { default = true; };
           Dee enableSteamUI = lib.mkEnableOption "Enable Steam Game Mode" // { default = false; };
          };

          config = {
            nixpkgs.config.permittedInsecurePackages = [ "qtwebengine-5.15.19" ];

            environment.systemPackages = with pkgs; [
              usbutils libusb1 alsa-firmware alsa-tools
              dialog disko mkpasswd networkmanager
              ryzenadj mangohud gamescope
            ];

            hardware.graphics.enable = true;
            hardware.graphics.extraPackages = with pkgs; [
              mesa vaapiIntel vaapiVdpau libvdpau-va-gl intel-media-driver
            ];

            isoImage.squashfsCompression = "gzip -Xcompression-level 1";
            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            branding = {
              enable = true;
              asciiArt = true;
              splash = true;
              wallpapers = true;
              wallpaperPaths = [ ./modules/assets/demod-wallpaper.jpg ];
            };

            users.users.nixos = {
              initialHashedPassword = lib.mkForce null;
              home = "/home/nixos";
              createHome = true;
              extraGroups = [ "audio" "jackaudio" "video" "networkmanager" ];
              shell = lib.mkForce pkgs.bashInteractive;
            };

            users.users.audio-user = lib.mkForce {
              isSystemUser = true;
              group = "audio-user";
              description = "Disabled in live ISO";
            };
            users.groups.audio-user = {};

            services.displayManager.autoLogin.enable = lib.mkDefault (!config.archibaldOS.enableSteamUI);
            services.displayManager.autoLogin.user = "nixos";

            services.displayManager.sddm.settings = {
              Users.HideUsers = "audio-user";
            };

            system.activationScripts.mkdirScreenshots = {
              text = ''
                mkdir -p /home/nixos/Pictures/Screenshots
                chown nixos:users /home/nixos/Pictures/Screenshots
              '';
            };

            jovian.devices.steamdeck = {
              enable = true;
              enableSoundSupport = true;
              enableOsFanControl = true;
            };

            boot.kernelPackages = pkgs.linuxPackages_jovian;

            jovian.steam = lib.mkIf config.archibaldOS.enableSteamUI {
              enable = true;
              autoStart = true;
              desktopSession = "plasma";
              user = "deck";
            };

            users.users.deck = lib.mkIf config.archibaldOS.enableSteamUI {
              isNormalUser = true;
              home = "/home/deck";
              description = "Steam Deck User";
              extraGroups = [ "wheel" "audio" "jackaudio" "video" "networkmanager" "input" ];
              initialPassword = "deck";
            };

            services.displayManager.autoLogin = lib.mkIf config.archibaldOS.enableSteamUI {
              enable = true;
              user = "deck";
            };
          };
        })
      ];
    };

    packages.${system}.deck-iso = self.nixosConfigurations.archibaldOS-deck.config.system.build.isoImage;
    packages.${system}.deck-image = self.nixosConfigurations.archibaldOS-deck.config.system.build.sdImage;

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        audacity supercollider carla helm surge zrythm
        qjackctl mangohud ryzenadj
      ];
    };
  };
}
