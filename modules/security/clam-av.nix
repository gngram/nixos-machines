{ lib, pkgs, config, ... }:

let
  inherit (lib) mkIf mkMerge mkEnableOption mkOption types optionalString concatStringsSep;
  cfg = config.services.clamavPlus;

  # Defaults used across clamd + clamonacc
  defaultSocket = "/run/clamav/clamd.sock";
  quarantineDir = cfg.on-access-scanning.config.quarantineDir or "/var/lib/clamav/quarantine";

  # Build clamonacc CLI from options
  clamonaccCmd =
    let
      includes =
        map (p: "--include=^${lib.escapeRegex p}(/.*)?$") cfg.on-access-scanning.includePath;
      excludes =
        (map (p: "--exclude-dir=${p}") cfg.on-access-scanning.excludePath)
        ++ [ "--exclude-dir=/proc" "--exclude-dir=/sys" "--exclude-dir=/dev" ];
      socket = cfg.config.LocalSocket or defaultSocket;
      extra  = cfg.on-access-scanning.config.extraArgs or [];
    in
    concatStringsSep " " ([
      "${pkgs.clamav}/bin/clamonacc"
      "--log=/var/log/clamonacc.log"
      "--fdpass"
      "--recursive"
      "--move=${quarantineDir}"
      "--socket=${socket}"
    ] ++ includes ++ excludes ++ extra);

  # Build periodic scan command: prefer clamdscan if daemon is on; otherwise clamscan
  periodicCmd =
    let
      useClamd = cfg.enable; # clamd enabled when module enabled
      scanner = if useClamd then "${pkgs.clamav}/bin/clamdscan" else "${pkgs.clamav}/bin/clamscan";

      # For periodic runs, we pass target paths as positional args;
      # also supply include/exclude regexes where supported.
      includeArgs =
        map (p: p) cfg.periodic-scanning.includePath;

      excludeArgs =
        # clamdscan forwards to clamd; clamscan supports --exclude-dir regex
        # Use conservative excludes for both.
        (map (p: "--exclude-dir=${p}") cfg.periodic-scanning.excludePath)
        ++ [ "--exclude-dir=/proc" "--exclude-dir=/sys" "--exclude-dir=/dev" ];

      baseArgs = [
        "--infected"
        "--recursive"
        "--log=/var/log/clamav/periodic.log"
      ];

      daemonArgs = if useClamd then [ "--multiscan" "--fdpass" ] else [];
      extra = cfg.periodic-scanning.config.extraArgs or [];
    in
    concatStringsSep " " ( [ scanner ] ++ baseArgs ++ daemonArgs ++ excludeArgs ++ includeArgs ++ extra );

in {
  options.services.clamavPlus = {
    # Top-level enable: turns on clamd and makes this module active.
    enable = mkEnableOption "ClamAV suite (clamd + optional on-access + periodic)";

    # clamd.conf settings pass-through (only common subset typed; rest via freeform)
    config = mkOption {
      type = types.attrsOf (types.oneOf [ types.str types.int types.bool ]);
      default = {
        LocalSocket = defaultSocket;
        FixStaleSocket = true;
        LogFile = "/var/log/clamd.log";
        LogTime = true;
        ExtendedDetectionInfo = true;
        HeuristicAlerts = true;
        # DetectPUA = false;  # uncomment to enable PUA detection
      };
      description = ''
        Settings for clamd (mapped to clamd.conf). Common fields like
        `LocalSocket`, `LogFile`, booleans/ints/strings are supported.
      '';
    };

    on-access-scanning = {
      enable = mkEnableOption "On-access scanning using clamonacc (fanotify)";
      includePath = mkOption {
        type = types.listOf types.path;
        default = [];
        example = [ "/home" "/var/downloads" ];
        description = "Directories to watch/scan on access.";
      };
      excludePath = mkOption {
        type = types.listOf types.path;
        default = [];
        example = [ "/var/cache" "/nix/store" ];
        description = "Directories to exclude from on-access scanning.";
      };
      config = mkOption {
        type = types.attrsOf (types.oneOf [ types.str types.path types.int types.bool (types.listOf types.str) ]);
        default = {
          quarantineDir = "/var/lib/clamav/quarantine";
          extraArgs = []; # e.g.: [ "--max-filesize=100M" ]
        };
        description = "Additional on-access settings (e.g., quarantineDir, extraArgs).";
      };
    };

    periodic-scanning = {
      enable = mkEnableOption "Periodic scanning via systemd timer";
      includePath = mkOption {
        type = types.listOf types.path;
        default = [ "/home" ];
        description = "Directories to scan during periodic runs.";
      };
      excludePath = mkOption {
        type = types.listOf types.path;
        default = [ "/nix/store" "/var/cache" ];
        description = "Directories to exclude during periodic runs.";
      };
      config = mkOption {
        type = types.attrsOf (types.oneOf [ types.str types.int types.bool (types.listOf types.str) ]);
        default = {
          schedule = "daily";  # systemd OnCalendar (e.g., '02:30', 'hourly', 'daily', 'Mon..Fri 02:00')
          extraArgs = [];      # e.g.: [ "--max-filesize=100M" "--bytecode=yes" ]
        };
        description = "Extra periodic scan settings; set `schedule` to a systemd OnCalendar value.";
      };
    };

    updater = {
      enable = mkEnableOption "freshclam updater service";
      config = mkOption {
        type = types.attrsOf (types.oneOf [ types.str types.int types.bool ]);
        default = { };
        description = "freshclam.conf overrides.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    #### clamd daemon (built on NixOS' built-in service)
    {
      services.clamav.daemon.enable = true;
      services.clamav.daemon.settings = cfg.config;

      #### updater (freshclam)
      services.clamav.updater.enable = cfg.updater.enable or true;
      services.clamav.updater.settings = cfg.updater.config or { };

      #### quarantine directory
      systemd.tmpfiles.rules = [
        "d ${quarantineDir} 0700 root root -"
      ];
    }

    #### On-access scanner service (clamonacc)
    (mkIf cfg.on-access-scanning.enable {
      systemd.services.clamonacc = {
        description = "ClamAV On-Access Scanner (fanotify)";
        after = [ "clamav-daemon.service" "clamav-freshclam.service" ];
        requires = [ "clamav-daemon.service" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = clamonaccCmd;
          Restart = "on-failure";
          RestartSec = "2s";
          # Needs CAP_SYS_ADMIN for fanotify? clamonacc typically runs as root.
        };
      };
    })

    #### Periodic scanning (service + timer)
    (mkIf cfg.periodic-scanning.enable {
      systemd.services."clamav-periodic-scan" = {
        description = "ClamAV periodic scan";
        after = [ "network-online.target" "clamav-daemon.service" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          # Be nice to the system:
          ExecStart = ''
            ${pkgs.util-linux}/bin/ionice -c3 ${periodicCmd}
          '';
        };
      };

      systemd.timers."clamav-periodic-scan" = {
        description = "Timer for ClamAV periodic scan";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = cfg.periodic-scanning.config.schedule or "daily";
          Persistent = true;
        };
      };
    })
  ]);
}

