{ config, pkgs, ... }:

{
  # Disable GDM and enable SDDM with Nordic theme and custom background
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.displayManager.sddm = {
    enable = true;
    theme = "nordic";
  };

  # Create custom background for SDDM
  environment.etc."sddm-wallpaper.svg".source = pkgs.writeText "sddm-wallpaper.svg" ''
    <svg width="1920" height="1080" xmlns="http://www.w3.org/2000/svg">
      <defs>
        <linearGradient id="grad1" x1="100%" y1="0%" x2="0%" y2="100%">
          <stop offset="0%" style="stop-color:yellow;stop-opacity:1" />
          <stop offset="100%" style="stop-color:purple;stop-opacity:1" />
        </linearGradient>
      </defs>
      <rect width="100%" height="100%" fill="url(#grad1)" />
      <text x="50%" y="50%" font-family="monospace" font-size="80" fill="black" text-anchor="middle">Stickman-OS</text>
    </svg>
  '';

  # Set SDDM theme to use the custom background
  environment.variables.SDDM_THEME_BACKGROUND = "/etc/sddm-wallpaper.svg";

  # Set the same custom wallpaper for the Wayland desktop environment
  environment.etc."wayland-wallpaper.svg".source = environment.etc."sddm-wallpaper.svg".source;

  # Enable River as the window manager with Wayland support and set up keybindings
  services.xserver = {
    enable = true;
    layout = "us"; # Adjust this to your keyboard layout if needed
    windowManager.river = {
      enable = true;
      wayland = true;
      extraConfig = ''
        # Keybindings in River

        # Open Kitty terminal with Super+Enter
        riverctl map normal Mod4+Return spawn kitty

        # Open Rofi application launcher with Super+D
        riverctl map normal Mod4+D spawn "rofi -show drun"

        # Close a window with Super+Q
        riverctl map normal Mod4+Q close

        # Kill a window with Super+Shift+Q
        riverctl map normal Mod4+Shift+Q kill

        # Move focused window with Super + Arrow Keys
        riverctl map normal Mod4+Left move left 100
        riverctl map normal Mod4+Right move right 100
        riverctl map normal Mod4+Up move up 100
        riverctl map normal Mod4+Down move down 100

        # Resize window with Super + Control + Arrow Keys
        riverctl map normal Mod4+Control+Left resize horizontal -100
        riverctl map normal Mod4+Control+Right resize horizontal 100
        riverctl map normal Mod4+Control+Up resize vertical -100
        riverctl map normal Mod4+Control+Down resize vertical 100

        # Shrink window size with Super + Control + Alt + Arrow Keys
        riverctl map normal Mod4+Control+Alt+Left resize horizontal 100
        riverctl map normal Mod4+Control+Alt+Right resize horizontal -100
        riverctl map normal Mod4+Control+Alt+Up resize vertical 100
        riverctl map normal Mod4+Control+Alt+Down resize vertical -100

        # Return to SDDM login screen with Super+Control+Alt+Delete
        riverctl map normal Mod4+Control+Alt+Delete spawn 'loginctl terminate-session $XDG_SESSION_ID'
      '';
    };
  };

  # Configure Waybar with interactive buttons, including the Stickman launcher button
  wayland.windowManager.waybar = {
    enable = true;
    extraConfig = ''
      {
        "layer": "top",
        "position": "top",
        "height": 35,
        "margin": 10,
        "modules-left": ["custom/launcher", "workspaces"],
        "modules-center": ["clock"],
        "modules-right": ["cpu", "memory", "network", "volume", "microphone"],

        # Stickman launcher button
        "custom/launcher": {
          "exec": "echo '☃'", # Simple stick figure placeholder icon
          "tooltip": "Launch Applications",
          "on-click": "rofi -show drun"
        },

        "clock": {
          "format": "{:%A, %B %d - %H:%M}",
          "interval": 60
        },

        "cpu": {
          "format": "CPU: {usage}%",
          "tooltip-format": "CPU Usage",
          "on-click": "kitty -e btop"
        },

        "memory": {
          "format": "RAM: {usedMem} MB",
          "tooltip-format": "RAM Usage",
          "on-click": "kitty -e btop"
        },

        "network": {
          "format": "{ifname} {ipaddr}",
          "tooltip-format": "Network: {ifname} with IP {ipaddr}",
          "on-click": "networkmanager_dmenu" # Opens NetworkManager controls
        },

        "volume": {
          "exec": "pamixer --get-volume-human",
          "tooltip": "Volume Control",
          "on-click": "pavucontrol" # Opens PulseAudio controls
        },

        "microphone": {
          "exec": "pamixer --default-source --get-volume-human",
          "tooltip": "Microphone Control",
          "on-click": "pavucontrol" # Opens PulseAudio controls
        },

        "style": {
          "bar": { "background": "#1E1E2EAA", "border-radius": 20, "padding": 8, "margin": 20 }
        }
      };
    '';
  };

  # Enable NetworkManager for network management
  networking.networkmanager.enable = true;

  # Enable PulseAudio for audio management
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Set up fonts and system-wide Monospace font
  fonts = {
    enableDefaultFonts = true;
    fonts = [ pkgs.dejavu_fonts pkgs.libreoffice-fonts pkgs.noto-fonts pkgs.noto-fonts-emoji ];
  };

  # Install system packages, including GTK and Qt theming with Kvantum, btop, and ePapirus icons
  environment.systemPackages = with pkgs; [
    river
    waybar
    kitty
    rofi
    sddm-theme-nordic
    kvantum
    qt5.qtbase
    qt5.qtstyleplugins
    qt5ct
    pamixer
    pavucontrol
    btop
    networkmanager_dmenu
    ePapirus-icon-theme
  ];

  # GTK and Qt theming with Kvantum and Materia Dark theme
  xsession.windowManager.kvantum = {
    enable = true;
    theme = "MateriaDark";
  };

  # Set environment variables for GTK and Qt themes and icon theme
  environment.variables = {
    GTK_THEME = "Materia:dark";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_STYLE_OVERRIDE = "kvantum";
    XDG_ICON_THEME = "ePapirus"; # Sets ePapirus as the icon theme system-wide
  };
}
