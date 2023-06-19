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
  users.users.root = {
    openssh.authorizedKeys.keyFiles = [
      (pkgs.fetchurl {
        # replace with your own ssh key!
        url = "https://github.com/mayniklas.keys";
        hash = "sha256-QW7XAqj9EmdQXYEu8EU74eFWml5V0ALvbQOnjk8ce/U=";
      })
    ];
  };

  ### Locales ###
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  system.stateVersion = "23.05";

}
