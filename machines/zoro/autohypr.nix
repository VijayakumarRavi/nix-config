{ pkgs }:

pkgs.writeShellScriptBin "autohypr" ''
    ${pkgs.swww}/bin/swww init &
    ${pkgs.swww}/bin/swww img /home/vijay/.config/wallpaper.png &
    ${pkgs.swaynotificationcenter}/bin/swaync &
    if [[ ! $(pgrep -f waybar) ]]; then
      ${pkgs.waybar}/bin/waybar &
    else
      echo "already running......"
    fi
    ${pkgs.xfce.thunar}/bin/thunar --daemon &
    ${pkgs.blueman}/bin/blueman-applet &
''

