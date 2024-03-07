#!/bin/bash

# Get the current directory
current_dir=$(pwd)

# Function to backup existing files
backup_and_replace() {
    local source="$1"
    local target="$2"

    # Check if the target file already exists in the home directory
    if [ -e "$target" ]; then
        # Backup existing file by adding a ".bak" extension
        mv "$target" "$target.bak"
        echo "Backed up existing file: $target to $target.bak"
    fi

    # Create a symbolic link in the home folder
    ln -s "$source" "$target"
    echo "Created a symbolic link for $(basename "$source") in $HOME"
}

# Loop through dotfiles in the current directory
for file in $(find . -maxdepth 1 -type f -name ".*" ! -name "." ! -name ".."); do
    # Extract the filename
    filename=$(basename "$file")

    # Call the function to backup and replace
    backup_and_replace "$current_dir/$filename" "$HOME/$filename"
done

CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}
NVIM_CONFIG=$CONFIG_HOME/nvim

backup_and_replace "$PWD/nvim" "$NVIM_CONFIG"
echo "Dotfiles linking complete."
