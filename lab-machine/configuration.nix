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

  #xfce
  services.displayManager.defaultSession = "xfce";
  services.xserver.desktopManager.xfce.enable = true;
    

  # Enable the GNOME Desktop Environment.
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;

  # Plasma6 and wayland
  /*
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.desktopManager.plasma6.enableQt5Integration = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kwallet
    kwallet-pam
    kwalletmanager
  ];
  */
  
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

  hardware = {
    graphics = {
      enable = true;
    };

    nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
    };
  };

  boot.initrd.kernelModules = [ "nvidia" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11_legacy535 ];
  nixpkgs.config.allowUnfreePredicate =  (pkg: false);

  services.xserver.videoDrivers = [ "nvidia" ];
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.gangaram = {
    isNormalUser = true;
    description = "Ganga Ram";
    extraGroups = [ "networkmanager" "wheel" "disk"];
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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINfyjcPGIRHEtXZgoF7wImA5gEY6ytIfkBeipz4lwnj6 Ganga.Ram@tii.ae"
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
  nixpkgs.config.nvidia.acceptLicense = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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
    wget
    qtcreator
    google-chrome  
    /*
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
    */
  ];

  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
  };
  services.tailscale.enable = true;

  systemd.services.sshd = {
    after = [ "multi-user.target" ];
    wants = [ "multi-user.target" ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };
  
  networking.firewall = {
    # enable = false;
	  allowPing = true;
  	allowedTCPPorts = [ 22 445 139 8080 5201 ];
  	allowedUDPPorts = [ 137 138 8080 5201  config.services.tailscale.port ];
  };

  system.stateVersion = "24.05";

}
