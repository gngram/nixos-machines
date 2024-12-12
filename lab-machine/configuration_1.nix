# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #(fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
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
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking = {
    #defaultGateway = "172.31.107.1";
    nameservers = ["8.8.8.8" "1.1.1.1"];
    interfaces.enp68s0 = {
      useDHCP = true;
      #ipv4.addresses = [{
      #address = "192.168.1.130";
      #prefixLength = 24;
      #}];
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
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.desktopManager.gnome.enable = true;
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  
  services.desktopManager.plasma6.enable = true;
  services.desktopManager.plasma6.enableQt5Integration = true;
  
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

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.graphics.enable = true;  
  hardware.opengl.enable = true;  
  hardware.nvidia.modesetting.enable = true;
  #hardware.nvidia.open = true;
  
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
    #  thunderbird
    ];
  };
  #services.fail2ban.enable = true;

  services.fail2ban = {
        enable = true;
        bantime = "15m";
        maxretry = 3;
        bantime-increment.enable = true;
        jails = {
          apache-nohome-iptables = ''
              # Block an IP address if it accesses a non-existent
              # home directory more than 5 times in 10 minutes,
              # since that indicates that it's scanning.
              filter   = apache-nohome
              action   = iptables-multiport[name=HTTP, port="http,https"]
              logpath  = /var/log/httpd/error_log*
              backend = auto
              findtime = 600
              bantime  = 600
              maxretry = 5
            '';
        };
      };
  services.tailscale = {
	enable = true;
	openFirewall = true;
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

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    kwallet
    kwallet-pam
    kwalletmanager
  ];
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
    google-chrome
    tailscale
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
  #  wget
  ];
  qt.enable = true;
  qt.platformTheme="kde";
  qt.style="breeze"; 
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.firejail.enable = true;
/*
  programs.gnupg.agent = {
     enable = true;
     enableSSHSupport = true;
  };
*/
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.openssh.settings.X11Forwarding = true;
  networking.firewall = {
	allowPing = true;
  	# Open ports in the firewall.
  	allowedTCPPorts = [ 22 445 139 8080 5201 ];
  	allowedUDPPorts = [ 137 138 8080 5201  config.services.tailscale.port ];
	# always allow traffic from your Tailscale network
	trustedInterfaces = [ "tailscale0" ];
  };

  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
