{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
  };


  outputs = { self, nixpkgs, ... }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
      };
      lib = pkgs.lib;
      stdenv = pkgs.stdenv;
    in
    {

      # See for further options:
      # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/proxmox-image.nix
      nixosConfigurations.proxmox-host = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-image.nix"
          ./configuration.nix
          {
            proxmox = {
              qemuConf = {
                # EFI support
                bios = "ovmf";
                cores = 4;
                memory = 4096;
              };
              qemuExtraConf = {
                onboot = "1";
                cpu = "host";
              };
            };
            nix.nixPath = [ "nixpkgs=${nixpkgs}" ];
            nix.registry.nixpkgs.flake = nixpkgs;
          }
        ];
      };

      packages.x86_64-linux = {
        # nix build .#proxmox-image
        proxmox-image = self.nixosConfigurations.proxmox-host.config.system.build.VMA;
        # nix build .#proxmox-image-uncompressed
        proxmox-image-uncompressed = stdenv.mkDerivation {
          name = "proxmox-image-uncompressed";
          dontUnpack = true;
          installPhase = ''
            # create output directory
            mkdir -p $out/

            # basename of the vma file (without .zst)
            export filename=$(basename ${self.packages.x86_64-linux.proxmox-image}/vzdump-qemu-nixos-*.vma.zst .zst)

            # decompress the vma file and write it to the output directory
            ${pkgs.zstd}/bin/zstd -d ${self.packages.x86_64-linux.proxmox-image}/vzdump-qemu-nixos-*.vma.zst -o $out/$filename
          '';
        };
      };

    };
}
