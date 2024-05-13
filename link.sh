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

#link .configs
home_configs_root=${XDG_CONFIG_HOME:-"$HOME/.config"}
repo_configs_root="$PWD/.config"

for repo_config_dir in "$repo_configs_root"/*; do
    if [ -d "$repo_config_dir" ]; then
        dir_name=$(basename "$repo_config_dir")
        original_dir="$home_configs_root/$dir_name"

        # Backup existing directory in ~/.config if it exists
        if [ -d "$original_dir" ]; then
            echo "Backing up existing directory: $original_dir"
            mv "$original_dir" "${original_dir}_backup"
        fi

        # Create the symbolic link in ~/.contig
        echo "Creating symbolic link: $original_dir -> $repo_config_dir"
        ln -s "$repo_config_dir" "$original_dir"
    fi
done

#Link tools
echo "linking files to /usr/local/bin"
sudo ln -s $PWD/tools/tms /usr/local/bin
sudo ln -s $PWD/tools/cht /usr/local/bin

echo "Dotfiles linking complete."
