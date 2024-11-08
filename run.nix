{ config, pkgs, ... }:

{
  # Enable audio and set up PulseAudio
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Install necessary system packages
  environment.systemPackages = with pkgs; [
    pulseaudio
    pavucontrol
    waybar
    rofi-wayland
    river
    kitty
    pcmanfm
    qt5ct
    materia-theme
    epapirus-icon-theme
    networkmanager
    btop
  ];

  # Disable GDM if starting from GNOME version
  services.xserver.displayManager.gdm.enable = false;

  # Enable SDDM with custom configuration
  services.xserver.displayManager.sddm = {
    enable = true;
    theme = "candy"; # Ensure this theme is available or replace if necessary
    extraConfig = ''
      Hostname=Stickman-OS
      Background=/path/to/your/sddm-background.svg # Replace with the correct path
    '';
  };

  # Enable Wayland and configure River as the window manager
  services.xserver = {
    enable = true;
    displayManager.defaultSession = "river";
    windowManager.river.enable = true;
  };

  # Waybar Configuration
  environment.etc."waybar/config" = {
    text = ''
      {
        "layer": "top",
        "position": "top",
        "margin": 5,
        "modules-left": [
          {
            "type": "custom/menu",
            "format": "",  # Placeholder icon for launcher
            "on-click": "rofi -show drun"
          },
          {
            "type": "workspaces",
            "max": 9,
            "urgent": true,
            "current-workspace": "underline",
            "non-empty": "dot",
            "empty": false
          }
        ],
        "modules-center": [
          {
            "type": "clock",
            "format": "%H:%M %p"
          }
        ],
        "modules-right": [
          {
            "type": "pulseaudio",
            "format": "{volume}% ",
            "tooltip": "Volume Control",
            "on-click": "pavucontrol"
          },
          {
            "type": "network",
            "format": "{essid} {ip4} ",
            "tooltip": "Network Status",
            "on-click": "nm-connection-editor"
          },
          {
            "type": "custom/btop",
            "format": " {cpu_usage}%  {mem_usage}MB",
            "on-click": "kitty -e btop"
          },
          {
            "type": "custom/power",
            "format": "",
            "on-click": "poweroff"
          }
        ]
      }
    '';
  };

  # GTK and QT theme configurations as per your requirements
  environment.etc."gtk-3.0/settings.ini".text = ''
    [Settings]
    gtk-theme-name = "Materia"
    gtk-icon-theme-name = "ePapirus"
    gtk-font-name = "monospace 11"
  '';

  # Ensure QT applications use the specified theme
  environment.variables = {
    QT_QPA_PLATFORMTHEME = "qt5ct";
    GTK_THEME = "Materia";
  };

  # Define keybindings for River using riverctl
  # This uses riverctl commands instead of configuration options
  environment.etc."river/init" = {
    text = ''
      # Modifier key
      mod="Mod4"

      # Open applications
      riverctl map normal $mod+Return spawn kitty
      riverctl map normal $mod+D spawn rofi -show drun

      # Close and kill windows
      riverctl map normal $mod+Q close
      riverctl map normal $mod+Shift+Q kill

      # Move windows around with arrow keys
      riverctl map normal $mod+Left move left 100
      riverctl map normal $mod+Right move right 100
      riverctl map normal $mod+Up move up 100
      riverctl map normal $mod+Down move down 100

      # Resize windows with Ctrl + Arrow keys
      riverctl map normal $mod+Ctrl+Left resize left 100
      riverctl map normal $mod+Ctrl+Right resize right 100
      riverctl map normal $mod+Ctrl+Up resize up 100
      riverctl map normal $mod+Ctrl+Down resize down 100

      # Return to SDDM login screen with Ctrl+Alt+Delete
      riverctl map normal $mod+Ctrl+Alt+Delete spawn sddm
    '';
    mode = "0755";
  };

  # Set wallpaper for Wayland and SDDM as specified
  environment.etc."wayland-wallpaper.svg".source = /path/to/your/wallpaper.svg;
  environment.etc."sddm/wallpaper.svg".source = /path/to/your/sddm-background.svg;
}
