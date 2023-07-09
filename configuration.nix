{ config, pkgs, lib, ... }: {

  ### SSH ###
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  ### Users ###
  users = {
    defaultUserShell = pkgs.zsh;
    users = {
      root = {
        openssh.authorizedKeys.keyFiles = [
          (pkgs.fetchurl {
            # replace with your own ssh key!
            url = "https://github.com/mayniklas.keys";
            hash = "sha256-QW7XAqj9EmdQXYEu8EU74eFWml5V0ALvbQOnjk8ce/U=";
          })
        ];
      };
    };
  };

  ### ZSH ###
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
  };

  # Needed for zsh completion of system packages, e.g. systemd
  environment.pathsToLink = [ "/share/zsh" ];

  ### Locales ###
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  ### Packages ###
  environment.systemPackages = with pkgs; [
    bash-completion
    git
    nixpkgs-fmt
    wget
    zsh
  ];

  ### settings specific to this VM setup ###
  # enable after installation!

  # # reduce size of the VM
  # services.fstrim = {
  #   enable = true;
  #   interval = "weekly";
  # };

  # fileSystems."/" = {
  #   device = "/dev/disk/by-label/nixos";
  #   autoResize = true;
  #   fsType = "ext4";
  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-label/ESP";
  #   fsType = "vfat";
  # };

  # boot.loader.grub = {
  #   version = 2;
  #   device = "nodev";
  #   efiSupport = true;
  #   efiInstallAsRemovable = true;
  # };

  # boot.initrd.availableKernelModules = [ "9p" "9pnet_virtio" "ata_piix" "uhci_hcd" "virtio_blk" "virtio_mmio" "virtio_net" "virtio_pci" "virtio_scsi" ];
  # boot.initrd.kernelModules = [ "virtio_balloon" "virtio_console" "virtio_rng" ];
  # boot.kernelModules = [ "kvm-intel" ];

  # boot.growPartition = true;

  services.qemuGuest.enable = true;

  ### Nix ###
  system.stateVersion = "23.05";

}
