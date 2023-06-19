# NixOS on Proxmox

I created this repository to quickly deploy a minimal NixOS VM on Proxmox.
Feel free to fork it and adapt it to your needs.
The image can be build locally, or by using the included GitHub action.

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
qmrestore ./vzdump-qemu-nixos-*.vma.zst 999 --unique true --storage ZFS_mirror
```

### Change the VM settings

It makes sense to expand the disk size of the VM.

### Boot the VM

Welcome to NixOS!

## TODO

- [ ] boot partition should be 512MB instead of 256MB
- [ ] Create a script to deploy the image to Proxmox
- [ ] Script should ask questions about the VM settings
- [ ] Script should expand the disk size of the VM
- [ ] Add documentation
