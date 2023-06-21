#!/usr/bin/env bash

# curl https://raw.githubusercontent.com/MayNiklas/nixos-proxmox/main/deploy.sh | bash

# variables
URL="https://download.mayniklas.de/img/nixos/proxmox-pve/$(curl -s 'https://download.mayniklas.de/img/nixos/proxmox-pve/current_version/info.txt')"

# styling
BGN=$(echo "\033[4;92m")
CL=$(echo "\033[m")
CROSS="${RD}✗${CL}"
DGN=$(echo "\033[32m")
RD=$(echo "\033[01;31m")

function exiting() {
    echo -e "Exiting..."
    sleep 2
    exit
}

function exit-script() {
    clear
    echo -e "⚠  User exited script \n"
    exit
}

function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
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

function get_vmid() {
    NEXTID=$(pvesh get /cluster/nextid)
    while true; do
        if VMID=$(whiptail --inputbox "Set Virtual Machine ID" 8 58 $NEXTID --title "VIRTUAL MACHINE ID" --cancel-button Exit-Script 3>&1 1>&2 2>&3); then
            if [ -z "$VMID" ]; then
                VMID="$NEXTID"
            fi
            if pct status "$VMID" &>/dev/null || qm status "$VMID" &>/dev/null; then
                echo -e "${CROSS}${RD} ID $VMID is already in use${CL}"
                sleep 2
                continue
            fi
            echo -e "${DGN}Virtual Machine ID: ${BGN}$VMID${CL}"
            break
        else
            exit-script
        fi
    done
}

function get_storage_location() {
    msg_info "Validating Storage"
    while read -r line; do
        TAG=$(echo $line | awk '{print $1}')
        TYPE=$(echo $line | awk '{printf "%-10s", $2}')
        FREE=$(echo $line | numfmt --field 4-6 --from-unit=K --to=iec --format %.2f | awk '{printf( "%9sB", $6)}')
        ITEM="  Type: $TYPE Free: $FREE "
        OFFSET=2
        if [[ $((${#ITEM} + $OFFSET)) -gt ${MSG_MAX_LENGTH:-} ]]; then
            MSG_MAX_LENGTH=$((${#ITEM} + $OFFSET))
        fi
        STORAGE_MENU+=("$TAG" "$ITEM" "OFF")
    done < <(pvesm status -content images | awk 'NR>1')
    VALID=$(pvesm status -content images | awk 'NR>1')
    if [ -z "$VALID" ]; then
        msg_error "Unable to detect a valid storage location."
        exit
    elif [ $((${#STORAGE_MENU[@]} / 3)) -eq 1 ]; then
        STORAGE=${STORAGE_MENU[0]}
    else
        while [ -z "${STORAGE:+x}" ]; do
            STORAGE=$(whiptail --title "Storage Pools" --radiolist \
                "Which storage pool you would like to use for NixOS?\nTo make a selection, use the Spacebar.\n" \
                16 $(($MSG_MAX_LENGTH + 23)) 6 \
                "${STORAGE_MENU[@]}" 3>&1 1>&2 2>&3) || exit
        done
    fi
    msg_ok "Using ${CL}${BL}$STORAGE${CL} ${GN}for Storage Location."
}

function download() {
    echo -e "Downloading NixOS image..."
    wget -q --show-progress $URL
}

function import_image() {
    echo -e "Importing NixOS image..."
    FILE=$(basename $URL)
    qmrestore ./$FILE $VMID --unique true --storage $STORAGE
    echo -e "Importing NixOS image... ${DGN}done${CL}"
    rm $FILE
    echo -e "Removing NixOS image... ${DGN}done${CL}"
    msg_ok "Completed Successfully!\n"
}

# run functions
pve_check
arch_check
get_vmid
get_storage_location
download
import_image
