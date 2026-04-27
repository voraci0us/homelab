# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      (fetchTarball "https://github.com/nix-community/nixos-vscode-server/tarball/master")
      (fetchTarball "https://github.com/Mic92/sops-nix/archive/master.tar.gz")
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];

  networking.hostName = "linus"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.hostId = "deadbeef";

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.voraci0us = {
    isNormalUser = true;
    description = "voraci0us";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFaT+GTdbZakPGhVyPuB8V9dfvpZbzqjfXyAm11ctfJA voraci0us"
    ];
    packages = with pkgs; [];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
     fluxcd
     git
     kubernetes-helm
     gnupg
     sqlite
     tmux
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
    };
  };

  services.tailscale = {
    enable = true;
  };

  services.k3s = {
    enable = true;
    role = "server";
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  security.sudo.wheelNeedsPassword = false;

  systemd.services.zfs-load-keys = {
    description = "Load ZFS encryption keys and mount datasets";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      load_key() {
        local ds=$1 keyfile=$2
        if [ "$(${pkgs.zfs}/bin/zfs get -H -o value keystatus "$ds")" != "available" ]; then
          ${pkgs.zfs}/bin/zfs load-key -L "file://$keyfile" "$ds"
        fi
      }

      ${pkgs.zfs}/bin/zpool import -a

      load_key tank/media  /root/keys/zfs-tank.key
      load_key fast/vm     /root/keys/zfs-fast.key
      load_key fast/k8s    /root/keys/zfs-fast.key
      load_key fast/data   /root/keys/zfs-fast.key

      ${pkgs.zfs}/bin/zfs mount -a || true
    '';
  };

  sops.gnupg.home = "/root/.gnupg";
  sops.gnupg.sshKeyPaths = [];
  sops.defaultSopsFile = ./secrets.yaml;
  sops.secrets.ssh_private_key = {
    owner = "voraci0us";
    mode = "0600";
    path = "/home/voraci0us/.ssh/id_ed25519";
  };

  systemd.services.clone-homelab-repo = {
    description = "Clone homelab repo if not present";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" "sops-nix.service" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "voraci0us";
    };
    script = ''
      if [ ! -d /home/voraci0us/homelab ]; then
        ${pkgs.git}/bin/git clone git@github.com:voraci0us/homelab.git /home/voraci0us/homelab
      fi
    '';
  };

  services.vscode-server.enable = true;
  systemd.user.services.auto-fix-vscode-server.wantedBy = [ "default.target" ];
}