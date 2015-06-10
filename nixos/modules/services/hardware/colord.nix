# colord daemon.

{ config, lib, pkgs, ... }:

with lib;

{

  ###### interface

  options = {

    services.colord = {

      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether to enable colord, a DBus service that manages color
          profiles for attached devices such as scanners and monitors.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf config.services.colord.enable {

    environment.systemPackages = [ pkgs.colord ];

    services.dbus.packages = [ pkgs.colord ];

    system.activationScripts.colord =
      ''
        mkdir -m 0755 -p /var/lib/colord
      '';

    systemd.services.colord = {
      description = "Manage, Install and Generate Color Profiles";
      serviceConfig = {
        Type = "dbus";
        BusName = "org.freedesktop.ColorManager";
        ExecStart = "${pkgs.colord}/libexec/colord";
        PrivateTmp = "yes";
      };
    };
  };

}
