{ lib, pkgs, ... }:
let
  lockCommand = "/run/current-system/sw/bin/noctalia-shell ipc call lockScreen lock";
  sessionIdle = pkgs.writeShellScriptBin "session-idle" ''
    exec ${lib.getExe pkgs.swayidle} -w \
      timeout 600 ${lib.escapeShellArg lockCommand} \
      before-sleep ${lib.escapeShellArg lockCommand}
  '';
in
{
  systemd.user.services.session-idle = {
    description = "Idle lock for Noctalia session";
    after = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = lib.getExe sessionIdle;
      Restart = "on-failure";
    };
  };
}
