{ config, pkgs, ... }:

let
  neovim-nightly-overlay = (import (builtins.fetchTarball {
    url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
  }));
in
{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.configurationLimit = 15;
    };

    # Thinkpad battery module for TLP
    kernelModules = [ "acpi_call" ];
    extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  };

  services.xserver = {
    enable = true;
    libinput.enable = true;

    displayManager.defaultSession = "xfce+i3";

    # Simple login screen
    displayManager.lightdm.greeters.mini = {
      enable = true;
      user = "elias";
      extraConfig = ''
        [greeter]
        show-password-label = false
        password-alignment = left
        [greeter-theme]
        text-color = "#080800"
        error-color = "#F8F8F0"
        background-image = ""
        background-color = "#1B1D1E"
        window-color = "#1B1D1E"
        border-color = "#080800"
        border-width = 0px
        layout-space = 0
        password-color = "#F8F8F0"
        password-background-color = "#1B1D1E"
      '';
    };

    # Xfce manages themes, default applications, mounting media, etc. When
    # first configuring a new system you'll want to run `xfce4-settings-manager`
    # to make stateful changes such as setting the window and icon styles.
    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
      };
    };

    # Use i3 with local config
    windowManager = {
      i3.enable = true;
    };
  };

  # Networking with connman
  networking.wireless = {
    enable = true;
    interfaces = [ "wlp0s20f3" ];
    networks = {
      # Fake ssid so NixOS creates wpa_supplicant.conf
      # otherwise the service fails and WiFi is not available.
      # https://github.com/NixOS/nixpkgs/issues/23196
      S4AKR00UNUN21W1NV2Y5MDDW8 = {};
    };
  };
  services.connman.enable = true;
  networking.firewall = {
    enable = true;
    # Allow ports needed for chromecast. See
    # https://github.com/NixOS/nixpkgs/issues/49630
    # Also open TCP ports for local development
    allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
    allowedTCPPorts = [ 8010 3000 4000 5432 ];
  };

  # Power management
  services.tlp.enable = true;
  systemd.services = {
    battery_threshold = {
      description = "Set battery charging thresholds.";
      path = [ pkgs.tpacpi-bat ];
      after = [ "basic.target" ];
      wantedBy = [ "multi-user.target" ];
      script = ''
        tpacpi-bat -s start 0 70
        tpacpi-bat -s stop 0 85
      '';
    };
  };

  services.avahi.enable = true;

  nixpkgs.overlays = [
    neovim-nightly-overlay
  ];

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    acpi
    arandr
    cloc
    coreutils
    connman-ncurses
    feh
    file
    firefox
    git
    htop
    (hunspellWithDicts [ hunspellDicts.en-us ])
    ntfs3g
    scrot
    stow
    tpacpi-bat
    tree
    vim_configurable
    wget
    xarchiver
    xcape
    xclip
    xdotool
    xorg.xmodmap
    zsh
    neovim-nightly
  ];

  fonts.fonts = with pkgs; [
    inconsolata
    font-awesome_5
  ];

  time.timeZone = "America/New_York";

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  programs.zsh.enable = true;

  users = {
    users.elias = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
    };
    defaultUserShell = pkgs.zsh;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "21.11";
  # Automatically check for updates within 21.11
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = https://nixos.org/channels/nixos-21.11;
}
