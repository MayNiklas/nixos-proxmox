#!/usr/bin/env bash

# curl https://raw.githubusercontent.com/MayNiklas/nixos-proxmox/main/deploy.sh | bash
# THIS SCRIPT IS A WORK IN PROGRESS

# variables
CROSS="${RD}✗${CL}"
URL="https://download.mayniklas.de/img/nixos/proxmox-pve/$(curl -s 'https://download.mayniklas.de/img/nixos/proxmox-pve/current_version/info.txt')"

function exiting() {
    echo -e "Exiting..."
    sleep 2
    exit
}

function pve_check() {
    # check if this is a Proxmox VE system
    if [ ! -f /usr/bin/pveversion ]; then
        echo -e "\n ${CROSS} This script is only for Proxmox VE systems."
        exiting
    fi
}

function arch_check() {
    # check if this is a 64-bit x86 system
    if [ "$(dpkg --print-architecture)" != "amd64" ]; then
        echo -e "\n ${CROSS} This script will only work on 64-bit x86 systems."
        exiting
    fi
}

function download() {
    echo -e "Downloading NixOS image..."
    wget -q --show-progress $URL
}

# run functions
pve_check
arch_check
download
