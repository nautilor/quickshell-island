{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.quickshell;
in
{
  options.programs.quickshell.enable = lib.mkEnableOption "quickshell";

  config = lib.mkIf cfg.enable {
    home.file.".config/quickshell/bin".source = ./modules;
    home.file.".config/quickshell/modules".source = ./bin;
    home.file.".config/quickshell/shell.qml".source = ./shell.qml;
  };
}
