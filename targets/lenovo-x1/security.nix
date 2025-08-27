{ config, pkgs, lib, ... }:

{
  services.clamavPlus = {
    enable = true;

    # clamd options
    config = {
      LocalSocket = "/run/clamav/clamd.sock";
      LogTime = true;
      ExtendedDetectionInfo = true;
    };

    # updater (freshclam)
    updater = {
      enable = true;
      config = {
        DatabaseMirror = "database.clamav.net";
      };
    };

    # on-access scanning
    on-access-scanning = {
      enable = true;
      includePath = [ "/home" "/var/downloads" ];
      excludePath = [ "/nix/store" "/var/cache" ];
      config = {
        quarantineDir = "/var/lib/clamav/quarantine";
        extraArgs = [ "--max-filesize=200M" ];
      };
    };

    # periodic scanning
    periodic-scanning = {
      enable = true;
      includePath = [ "/home" "/srv/share" ];
      excludePath = [ "/nix/store" "/var/cache" ];
      config = {
        schedule = "02:30";     # daily at 02:30
        extraArgs = [ "--bytecode=yes" ];
      };
    };
  };
}

