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