{ config, pkgs, ... }:

let
  # Define the wallpaper path, replace with the actual path if necessary
  wallpaperPath = "/etc/nixos/wallpaper.svg";
in

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Set the hostname
  networking.hostName = "nixos";

  # Install necessary system packages with Qt prioritization
  environment.systemPackages = with pkgs; [
    git
    river
    waybar
    rofi-wayland
    kitty
    pcmanfm-qt # Qt-based file manager
    epapirus-icon-theme
    materia-kde # Use Materia theme adapted for Qt/KDE
    qt5.qtwayland # Qt Wayland support
    pulseaudio
    networkmanager
    btop # For monitoring CPU and RAM
    lxqt # Qt desktop components for additional Qt integration
    gtk3 # GTK libraries for compatibility with GTK apps
    gtk4
  ];

  # Enable SDDM with custom theme and wallpaper
  services.sddm = {
    enable = true;
    theme = "materia";
    wayland = true;
    settings = {
      General = {
        Background = "${wallpaperPath}";
      };
    };
  };

  # Enable both X11 and Wayland support
  services.xserver = {
    enable = true; # Enable X11 support
    layout = "us";
    xkbOptions = "terminate:ctrl_alt_bksp";
    windowManager.river.enable = true; # Enable River for Wayland
  };

  # Configure Wayland wallpaper and SDDM background
  environment.etc."wayland-wallpaper.svg".source = wallpaperPath;
  environment.etc."sddm-wallpaper.svg".source = wallpaperPath;

  # Waybar configuration with floating and rounded design
  services.waybar = {
    enable = true;
    config = {
      "layer-shell" = {
        layer = "top";
        height = 35;
        margin-top = 5;
        margin-bottom = 5;
        radius = 10; # Rounded corners
        background-color = "#1E1E1E";
        font-family = "monospace";
        font-size = 12;
        items = ["left", "center", "right"];
        left = [
          { "icon": "", "action": "rofi -show drun" } # Rofi launcher
        ];
        center = [
          { "text": "CPU: $(cpu_usage)% | RAM: $(ram_usage)% | Vol: $(volume)%" }
        ];
        right = [
          { "text": "Time: $(time)" },
          { "icon": "", "action": "poweroff" } # Power menu
        ];
      };
    };
  };

  # Custom keybindings for River window manager
  xsession.windowManager.command = ''
    riverctl map normal Mod4 Return spawn kitty
    riverctl map normal Mod4 d spawn "rofi -show drun"
    riverctl map normal Mod4+Shift Q close
    riverctl map normal Mod4+Ctrl Arrow focus-view in-direction
    riverctl map normal Mod4+Ctrl+Shift Arrow resize
  '';

  # Enable and configure Pulseaudio and NetworkManager
  services.pulseaudio.enable = true;
  networking.networkmanager.enable = true;

  # Set environment variables for fonts and GTK/Qt theme integration
  environment.variables = {
    FONT_FAMILY = "monospace";
    QT_QPA_PLATFORM = "wayland"; # Ensure Qt applications use Wayland
    QT_STYLE_OVERRIDE = "Breeze"; # Breeze style for Qt
    GTK_THEME = "Materia"; # GTK theme matching Qt theme
  };

  # Configure icons and theme
  environment.etc."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name = "Materia"
    gtk-icon-theme-name = "ePapirus"
    gtk-font-name = "monospace 11"
  '';

  # Waybar custom config for CPU/RAM/Volume monitoring
  waybar.config = {
    layer-shell = {
      center = [
        { text = "CPU: $(cpu_usage)% | RAM: $(ram_usage)% | Vol: $(volume)%" }
      ];
      left = [
        { text = "Launcher", icon = "", action = "rofi -show drun" }
      ];
      right = [
        { text = "Time: $(time)", icon = "" },
        { text = "Shutdown", icon = "", action = "poweroff" }
      ];
    };
  };
}
