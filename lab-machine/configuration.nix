# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.binfmt.emulatedSystems = [
    "riscv64-linux"
    "aarch64-linux"
  ];
 
  boot.kernelModules = [ "kvm-amd" ];

  networking.hostName = "ganga-ssrc"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;
  networking = {
    nameservers = ["8.8.8.8" "1.1.1.1"];
    interfaces.enp68s0 = {
      useDHCP = true;
    };
  };

  # Set your time zone.
  time.timeZone = "Asia/Dubai";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.desktopManager.gnome.enable = true;

  # Plasma6 and wayland
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.desktopManager.plasma6.enableQt5Integration = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kwallet
    kwallet-pam
    kwalletmanager
  ];
  
  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  #services.vscode-server.enable = true;

  # Enable sound with pipewire.
  #sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;  
  hardware.nvidia.modesetting.enable = true;
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gangaram = {
    isNormalUser = true;
    description = "Ganga Ram";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      git
      vim
      gtkterm
      binutils
      rustc
      cargo
      kate
      vscode-fhs
      slack
      teams-for-linux
      notepadqq
      meld
    ];
  };

  programs = {
    ssh = {
      startAgent = true;
      extraConfig = ''
        host ghaf-net
             user root
             hostname 192.168.1.131
        host ghaf-host
             user root
             hostname 192.168.101.2
             proxyjump ghaf-net
      '';
    };
  };

  nix.settings.trusted-users = ["root" "@wheel"];
  nix.settings.substituters = [ "https://cuda-maintainers.cachix.org" ];
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kate
    meld
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    nettools
    rustc
    cargo
    firefox
    plasma-theme-switcher
    kdePackages.breeze
    kdePackages.breeze-grub
    kdePackages.breeze-plymouth
    kdePackages.breeze-icons
    kdePackages.audiotube #yt music
    kdePackages.dolphin #File browser
    kdePackages.ghostwriter #md file
    kdePackages.gwenview
    kdePackages.kalk
    kdePackages.yakuake
    wget
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.X11Forwarding = true;
  
  networking.firewall = {
    # enable = false;
	  allowPing = true;
  	allowedTCPPorts = [ 22 445 139 8080 5201 ];
  	allowedUDPPorts = [ 137 138 8080 5201  config.services.tailscale.port ];
  };

  system.stateVersion = "24.05";

}
