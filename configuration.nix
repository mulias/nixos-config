# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  services.xserver = {
    enable = true;
    libinput.enable = true;

    desktopManager = {
      default = "xfce";
      xterm.enable = false;
      xfce = {
        enable = true;
        noDesktop = true;
        enableXfwm = false;
        thunarPlugins = [pkgs.xfce.thunar-archive-plugin];
      };
    };
    windowManager.i3.enable = true;
  };

  networking.wireless = {
    enable = true;
    networks = {
      # Fake ssid so NixOS creates wpa_supplicant.conf
      # otherwise the service fails and WiFi is not available.
      # https://github.com/NixOS/nixpkgs/issues/23196
      S4AKR00UNUN21W1NV2Y5MDDW8 = {};
    };
  };
  networking.connman.enable = true;

  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    arandr
    coreutils
    connman-ncurses
    firefox
    git
    htop
    (hunspellWithDicts [ hunspellDicts.en-us ])
    killall
    scrot
    stow
    tree
    vim
    wget
    xarchiver
    xcape
    xclip
    xorg.xmodmap
    zsh
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
  system.stateVersion = "19.03";
}
