{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  system = {
    stateVersion = "24.05";

    autoUpgrade = {
      enable = true;
      channel = https://nixos.org/channels/nixos-24.05;
    };
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_5_15;

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      grub.configurationLimit = 15;
    };
  };

  services = {
    xserver = {
      enable = true;

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

      windowManager.i3.enable = true;

      displayManager.lightdm = {
        enable = true;

        greeters.gtk = {
          enable = true;
          theme.name = "Adapta";
          iconTheme.name = "Arc";
          cursorTheme.name = "Default";
          indicators = [ "~session" "~spacer" "~power" ];
          extraConfig = ''
            background = #2E84EC
          '';
        };
      };
    };

    displayManager.defaultSession = "xfce+i3";

    libinput.enable = true;

    connman.enable = true;

    printing.enable = true;

    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };

  networking = {
    wireless = {
      enable = true;
      interfaces = [ "wlp0s20f3" ];
    };

    firewall = {
      enable = true;
      # Allow ports needed for chromecast. See
      # https://github.com/NixOS/nixpkgs/issues/49630
      # Also open TCP ports for local development
      allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
      allowedTCPPorts = [ 8010 3000 4000 5432 55555 4567 ];
    };
  };

  programs = {
    dconf.enable = true;

    gnupg.agent = {
       enable = true;
       enableSSHSupport = true;
    };

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-media-tags-plugin
        thunar-volman
      ];
    };

    zsh.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    (hunspellWithDicts [ hunspellDicts.en-us ])
    (polybar.override { i3Support = true; pulseSupport = true; })
    acpi
    adapta-gtk-theme
    alsa-utils
    arandr
    arc-icon-theme
    baobab
    bat
    brightnessctl
    catdocx
    cloc
    connman-gtk
    connman-ncurses
    coreutils
    direnv
    diskus
    emacs
    fd
    feh
    ffmpeg
    figlet
    file
    firefox
    fzf
    git
    gnome.file-roller
    gnupg
    htop
    hyperfine
    jless
    lighttpd
    links2
    mplayer
    neovim
    ntfs3g
    pandoc
    pavucontrol
    ripgrep
    scrot
    silver-searcher
    stow
    tpacpi-bat
    tree
    universal-ctags
    unzip
    vim_configurable
    vlc
    wget
    xarchiver
    xcape
    xclip
    xdotool
    xorg.xmodmap
    zoom-us
    zsh
  ];

  fonts.packages = with pkgs; [ inconsolata font-awesome_5 ];

  time.timeZone = "America/New_York";

  virtualisation.docker.enable = true;

  users = {
    users.elias = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "docker" ];
    };
    defaultUserShell = pkgs.zsh;
  };
}
