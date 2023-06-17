# NixOS on Proxmox

## Deployment

### Build the image

```sh
# build VMA image
nix build '.#proxmox-image'
```

### Upload the image to Proxmox

Upload the image to a location, that is accessible by Proxmox.

### Create a VM on Proxmox

```sh
# import the VM from VMA image
# unique is required to randomize the MAC address of the network interface
# storage is the name of the storage, where we create the VM
qmrestore ./vzdump-qemu-nixos-23.05.20230616.c7ff1b9.vma.zst 999 --unique true --storage ZFS_mirror
```

### Change the VM settings

It makes sense to expand the disk size of the VM.

### Boot the VM

Welcome to NixOS!

## TODO

- [x] Make sure the image is bootable
- [x] Make sure the image contains all relevant settings
- [ ] Create CI workflows to build the image and publish it
- [ ] Create a script to deploy the image to Proxmox
