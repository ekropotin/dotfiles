#!/bin/bash

# Dotfiles setup script
# This script creates symlinks for dotfiles from configs folder
# It processes common configs first, then platform-specific ones
# Only processes dotfiles (files starting with .) and .config directories

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$SCRIPT_DIR/configs"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

# Detect platform
detect_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "mac"
    else
        echo "unknown"
    fi
}

# Create backup directory if it doesn't exist
create_backup_dir() {
    if [[ ! -d "$BACKUP_DIR" ]]; then
        mkdir -p "$BACKUP_DIR"
        echo -e "${BLUE}Created backup directory: $BACKUP_DIR${NC}"
    fi
}

# Backup file or directory
backup_item() {
    local item="$1"
    local backup_path="$BACKUP_DIR/$(basename "$item")"
    
    if [[ -e "$item" ]]; then
        # If backup already exists, add a number suffix
        local counter=1
        local original_backup_path="$backup_path"
        while [[ -e "$backup_path" ]]; do
            backup_path="${original_backup_path}_$counter"
            ((counter++))
        done
        
        mv "$item" "$backup_path"
        echo -e "${YELLOW}Backed up: $item -> $backup_path${NC}"
        return 0
    fi
    return 1
}

# Create symlink for a file/directory
create_symlink() {
    local source="$1"
    local target="$2"
    
    # Backup existing file/directory if it exists
    if [[ -e "$target" ]]; then
        backup_item "$target"
    fi
    
    # Create parent directory if it doesn't exist
    local parent_dir="$(dirname "$target")"
    if [[ ! -d "$parent_dir" ]]; then
        mkdir -p "$parent_dir"
        echo -e "${BLUE}Created directory: $parent_dir${NC}"
    fi
    
    # Create symlink
    ln -sf "$source" "$target"
    echo -e "${GREEN}Created symlink: $target -> $source${NC}"
}

# Process dotfiles in a directory
process_dotfiles() {
    local config_dir="$1"
    local description="$2"
    
    if [[ ! -d "$config_dir" ]]; then
        echo -e "${YELLOW}Directory $config_dir does not exist, skipping...${NC}"
        return
    fi
    
    echo -e "\n${BLUE}Processing $description dotfiles...${NC}"
    
    # Process only dotfiles (files starting with .)
    find "$config_dir" -maxdepth 1 -name ".*" -type f | while read -r file; do
        if [[ "$(basename "$file")" != ".DS_Store" ]]; then
            local target="$HOME/$(basename "$file")"
            create_symlink "$file" "$target"
        fi
    done
    
    # Process .config directory if it exists
    local config_subdir="$config_dir/.config"
    if [[ -d "$config_subdir" ]]; then
        echo -e "\n${BLUE}Processing .config subdirectories for $description...${NC}"
        
        # Ensure ~/.config exists
        if [[ ! -d "$HOME/.config" ]]; then
            mkdir -p "$HOME/.config"
            echo -e "${BLUE}Created directory: $HOME/.config${NC}"
        fi
        
        # Process each subdirectory in .config
        find "$config_subdir" -maxdepth 1 -type d ! -path "$config_subdir" | while read -r subdir; do
            local subdir_name="$(basename "$subdir")"
            local target="$HOME/.config/$subdir_name"
            create_symlink "$subdir" "$target"
        done
    fi
}

# Symlink keyd config to /etc/keyd and enable the service (Linux only)
setup_keyd() {
    local source="$CONFIGS_DIR/linux/etc/keyd/default.conf"
    local target="/etc/keyd/default.conf"

    if [[ ! -f "$source" ]]; then
        return
    fi

    if ! command -v keyd >/dev/null 2>&1; then
        echo -e "${YELLOW}keyd not installed, skipping keyd setup${NC}"
        return
    fi

    echo -e "\n${BLUE}Setting up keyd config (requires sudo)...${NC}"

    sudo mkdir -p /etc/keyd
    if [[ -e "$target" && ! -L "$target" ]]; then
        sudo mv "$target" "$target.backup_$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backed up existing $target${NC}"
    fi
    sudo ln -sf "$source" "$target"
    echo -e "${GREEN}Linked $target -> $source${NC}"

    sudo systemctl enable --now keyd
    sudo systemctl reload keyd 2>/dev/null || sudo systemctl restart keyd
    echo -e "${GREEN}keyd service enabled and reloaded${NC}"
}

# Symlink bluetooth main.conf + udev rule that disables autosuspend on the
# internal BT controller (Linux only). See the file headers for rationale.
setup_bluetooth() {
    local bt_source="$CONFIGS_DIR/linux/etc/bluetooth/main.conf"
    local bt_target="/etc/bluetooth/main.conf"
    local udev_source="$CONFIGS_DIR/linux/etc/udev/rules.d/50-bluetooth-no-autosuspend.rules"
    local udev_target="/etc/udev/rules.d/50-bluetooth-no-autosuspend.rules"
    local resume_script_source="$CONFIGS_DIR/linux/etc/bluetooth/resume-reconnect.sh"
    local resume_script_target="/etc/bluetooth/resume-reconnect.sh"
    local resume_unit_source="$CONFIGS_DIR/linux/etc/systemd/system/bt-resume-reconnect.service"
    local resume_unit_target="/etc/systemd/system/bt-resume-reconnect.service"

    if [[ ! -f "$bt_source" || ! -f "$udev_source" ]]; then
        return
    fi

    if ! command -v bluetoothctl >/dev/null 2>&1; then
        echo -e "${YELLOW}bluez not installed, skipping bluetooth setup${NC}"
        return
    fi

    echo -e "\n${BLUE}Setting up bluetooth config (requires sudo)...${NC}"

    sudo mkdir -p /etc/bluetooth /etc/udev/rules.d

    # bluetooth main.conf must be a real file: bluetoothd's systemd unit
    # sets ProtectHome=true, so a symlink into ~/sources/dotfiles is
    # unreadable to the daemon ("Permission denied" on load_config).
    if [[ -e "$bt_target" && ! -L "$bt_target" ]]; then
        sudo mv "$bt_target" "$bt_target.backup_$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backed up existing $bt_target${NC}"
    elif [[ -L "$bt_target" ]]; then
        sudo rm "$bt_target"
    fi
    sudo install -m 644 -o root -g root "$bt_source" "$bt_target"
    echo -e "${GREEN}Installed $bt_target from $bt_source${NC}"

    # udev rule is symlinked: udev has no ProtectHome sandbox.
    if [[ -e "$udev_target" && ! -L "$udev_target" ]]; then
        sudo mv "$udev_target" "$udev_target.backup_$(date +%Y%m%d_%H%M%S)"
        echo -e "${YELLOW}Backed up existing $udev_target${NC}"
    fi
    sudo ln -sf "$udev_source" "$udev_target"
    echo -e "${GREEN}Linked $udev_target -> $udev_source${NC}"

    sudo udevadm control --reload
    # Re-apply rules to the live BT device so power/control flips without a reboot.
    sudo udevadm trigger --action=add --attr-match=idVendor=0489 --attr-match=idProduct=e0d0
    sudo systemctl restart bluetooth
    echo -e "${GREEN}bluetooth service restarted with new config${NC}"

    # Resume hook: after a long suspend, run a discovery window so bonded BLE
    # devices (LIFT mouse) re-attach on the first click. Installed as real
    # files (systemd units / scripts run cleanest without symlinks into $HOME).
    sudo install -m 755 -o root -g root "$resume_script_source" "$resume_script_target"
    sudo install -m 644 -o root -g root "$resume_unit_source" "$resume_unit_target"
    sudo systemctl daemon-reload
    sudo systemctl enable bt-resume-reconnect.service
    echo -e "${GREEN}bt-resume-reconnect.service installed and enabled${NC}"
}

# Main execution
main() {
    echo -e "${GREEN}Starting dotfiles setup...${NC}"
    echo -e "${BLUE}Note: Only processing dotfiles (files starting with .) and .config directories${NC}"
    
    # Check if configs directory exists
    if [[ ! -d "$CONFIGS_DIR" ]]; then
        echo -e "${RED}Error: configs directory not found at $CONFIGS_DIR${NC}"
        exit 1
    fi
    
    # Create backup directory
    create_backup_dir
    
    # Process common dotfiles first
    process_dotfiles "$CONFIGS_DIR/common" "common"
    
    # Detect platform and process platform-specific dotfiles
    PLATFORM=$(detect_platform)

    if [[ "$PLATFORM" == "unknown" ]]; then
        echo -e "${YELLOW}Warning: Unknown platform, skipping platform-specific configs${NC}"
    else
        echo -e "\n${BLUE}Detected platform: $PLATFORM${NC}"
        process_dotfiles "$CONFIGS_DIR/$PLATFORM" "$PLATFORM"

        if [[ "$PLATFORM" == "linux" ]]; then
            setup_keyd
            setup_bluetooth
        fi
    fi
    
    echo -e "\n${GREEN}Dotfiles setup completed!${NC}"
    
    # Show backup information
    if [[ -d "$BACKUP_DIR" ]] && [[ "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]]; then
        echo -e "${YELLOW}Backups created in: $BACKUP_DIR${NC}"
        echo -e "${YELLOW}You can remove this directory if everything works correctly${NC}"
    else
        # Remove empty backup directory
        rmdir "$BACKUP_DIR" 2>/dev/null || true
    fi
}

# Run main function
main "$@" 