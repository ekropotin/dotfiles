#!/usr/bin/env bash
set -euo pipefail

REPO_DIR=$(pwd)
OS="$(uname -s)"

# Resolve user directories for VSCode and Cursor
case "$OS" in
    Darwin)
        VSCODE_USER="$HOME/Library/Application Support/Code/User"
        CURSOR_USER="$HOME/Library/Application Support/Cursor/User"
        ;;
    Linux)
        VSCODE_USER="$HOME/.config/Code/User"
        CURSOR_USER="$HOME/.config/Cursor/User"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

echo "🔧 Bootstrapping config from $REPO_DIR"
echo "   VSCode User dir: $VSCODE_USER"
echo "   Cursor User dir: $CURSOR_USER"

mkdir -p "$VSCODE_USER" "$CURSOR_USER"

link_file() {
    local src="$REPO_DIR/$1"
    local dest="$2/$1"

    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
        echo "Backing up existing $dest to $dest.bak"
        mv "$dest" "$dest.bak"
    fi

    if [ -L "$dest" ]; then
        echo "Removing old symlink $dest"
        rm "$dest"
    fi

    echo "Linking $src -> $dest"
    ln -s "$src" "$dest"
}

bootstrap_editor() {
    local editor_name="$1"
    local user_dir="$2"
    echo "➡️  Setting up $editor_name"

    for file in settings.json keybindings.json; do
        link_file "$file" "$user_dir"
    done

    if [ -d "$REPO_DIR/snippets" ]; then
        link_file "snippets" "$user_dir"
    fi

    if [ -f "$REPO_DIR/extensions.txt" ]; then
        echo "Installing extensions for $editor_name"
        if command -v "$editor_name" >/dev/null 2>&1; then
            xargs -n1 "$editor_name" --install-extension < "$REPO_DIR/extensions.txt" || echo "⚠️  Some extensions failed to install for $editor_name"
        else
            echo "⚠️  $editor_name CLI not found, skipping extensions install"
        fi
    fi
}

# Bootstrap both editors
bootstrap_editor "code" "$VSCODE_USER"
bootstrap_editor "cursor" "$CURSOR_USER"

echo "✅ Bootstrap complete for VSCode and Cursor"
