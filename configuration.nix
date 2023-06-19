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

  ### Nix ###
  system.stateVersion = "23.05";

}
