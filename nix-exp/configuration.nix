# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

/*
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
sudo nix-channel --update
*/


# this configuration aims a regular desktop use with kde
let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
  stdenv.mkDerivation { … } # this should not work, investigate ?
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # cachix
  nix.settings = {
    substituters = ["https://hyprland.cachix.org"];
    trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
  };


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # experimental features for ease of use
  nix.settings.experimental-features = [ "nix-command flakes" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enables bluetooth
  hardware.bluetooth.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "ja_JP.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # Enable the X11 windowing system : needed for sddm even if wayland is used
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # exculde packages from the kde install - does not seem to exclude kwrited and kwalletmanager
  services.xserver.desktopManager.plasma5.excludePackages = with pkgs.libsForQt5; [
  elisa
  kwrited
  kwalletmanager
  ];

  # exclude xterm
  services.xserver.excludePackages = [ pkgs.xterm ];
  services.xserver.desktopManager.xterm.enable = false;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "dvorak-alt-intl";
  };

  # Configure console keymap
  console.keyMap = "dvorak";

    # fonts, copied from the nixos wiki
  fonts.fonts = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ];

  # jp IME : fcitx5
  # TODO : discover why does it only work on apps launched from the terminal
  i18n.inputMethod = {
    enabled = "fcitx5";
    fcitx5.addons = with pkgs; [ fcitx5-mozc fcitx5-configtool libsForQt5.fcitx5-qt fcitx5-gtk fcitx5-lua ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kiuw = {
    isNormalUser = true;
    description = "kiuw";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # by default
      # firefox
      # kate
      thunderbird
      librewolf
      mullvad-vpn

      # developpement & shell
      python311
      python310Packages.pip
      lua5_4
      fish

      # media consumption & editing

      ## mpv and mining
      mpv
      unstable.anki-bin # anki is outdated -> use the flatpak if the version is not recent enough
      unstable.obs-studio
      unstable.mkvtoolnix-cli
      vokoscreen-ng # screen recorder to try ?
      tesseract5 # for OCR ? why not
      kdenlive
      mediainfo
      ff2mpv # browser extension

      # etc
      libreoffice
      keepassxc
      libsForQt5.ark
      gparted
      qbittorrent
      libsForQt5.kdeconnect-kde
      libsForQt5.kpmcore # required for partition-manager
      partition-manager

      # emulation and games
      unstable.ryujinx
      unstable.yuzu
      unstable.ppsspp
      unstable.mgba
      unstable.pcsx2
      unstable.duckstation
      unstable.dolphin-emu-beta
      unstable.melonDS
      unstable.osu-lazer-bin # the bin package has online support
    ];
  };

  # package overwrites for mpv:

  nixpkgs.overlays = [
    (self: super: {
      mpv = super.mpv.override {
        scripts = [
          self.mpvScripts.mpris
          self.mpvScripts.thumbnail
          self.mpvScripts.autoload
          self.mpvScripts.mpvacious
          self.mpvScripts.mpv-playlistmanager
          self.mpvScripts.youtube-quality
          # self.mpvScripts.webtorrent-mpv-hook # is in unstable
          ];
      };
    })
  ];

  environment.sessionVariables = {
    GTK_IM_MODULE="fcitx";
    QT_IM_MODULE="fcitx";
    XMODIFIERS="@im=fcitx";
  };



  # enable flatpak
  services.flatpak.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # Installed "by default" for all users
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    wireguard-tools

    # testing if it will work with fcitx this way ( answer : no )
    firefox
    kate

    libwebp

    # this version sadly uses bubblewrap, who limits our possibilites with images
    unstable.anki-bin # anki is outdated -> use the flatpak if the version is not recent enough
  ];

  # program options and customisations : haven't found a good way yet to configure firefox
  # programs.firefox.policies = {"ExtensionSettings" : { "install_url" = "https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/?utm_source=addons.mozilla.org&utm_medium=referral&utm_content=search" }};

  # doesn't seem to work
  programs.firefox.nativeMessagingHosts.ff2mpv = true;
  programs.firefox.nativeMessagingHosts.tridactyl = true;

  # acivates the partition manager
  programs.partition-manager.enable = true;

  ### VPN
  services.mullvad-vpn.enable = true;
  programs.kdeconnect.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
