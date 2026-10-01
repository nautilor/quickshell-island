{ config, lib, ... }:

let
  cfg = config.programs.quickshell-island;
in
{
  options.programs.quickshell-island.enable = lib.mkEnableOption "Quickshell Island";

  config = lib.mkIf cfg.enable {
    xdg.configFile."quickshell/bin".source = ./bin;
    xdg.configFile."quickshell/modules".source = ./modules;
    xdg.configFile."quickshell/shell.qml".source = ./shell.qml;
  };
}
