# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  security.apparmor.enable = true;
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = ["systemd.debug_shell=1"];
  boot.binfmt.emulatedSystems = [
    "riscv64-linux"
    "aarch64-linux"
  ];
 
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  networking.hostName = "Vatapi";
  # networking.wireless.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

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
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gangaram = {
    isNormalUser = true;
    description = "Ganga Ram";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      firefox
      git
      vim
      gtkterm
      binutils
      rustc
      cargo
    ];
  };

  nix.settings.trusted-users = ["root" "@wheel"];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    git
    nettools
    rustc
    cargo
    firefox
    meld
    vim
    vscode
  #  wget
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.allowPing = true;
  networking.firewall.allowedTCPPorts = [ 22 445 139 8080 ];
  networking.firewall.allowedUDPPorts = [ 137 138 8080 ];
 
 system.stateVersion = "24.11";

}
