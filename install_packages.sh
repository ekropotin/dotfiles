#!/bin/bash

set -e

# Detect OS and install appropriate package manager
OS=$(uname -s)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd packages

# Handle macOS
if [[ "$OS" == "Darwin" ]]; then
    echo "Detected macOS"
    echo "Installing Homebrew"
    if ! command -v brew &> /dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew already installed"
    fi
    echo "Installing essential packages"
    xargs brew install < essentials.txt

    echo "Installing brew packages"
    brew trust koekeishiya/formulae
    brew bundle
fi

# Handle Arch Linux
if [[ "$OS" == "Linux" ]] && ([[ -f /etc/arch-release ]] || command -v pacman &> /dev/null); then
    echo "Detected Arch Linux"

    echo "Updating package database"
    sudo pacman -Syy
    sudo pacman -S python-filelock

    echo "Installing essential packages"
    sudo pacman -S --needed - < essentials.txt

    echo "Installing official packages"
    official_pkgs="$(grep -vE '^[[:space:]]*(#|$)' pkglist.txt || true)"
    if [[ -n "$official_pkgs" ]]; then
        sudo pacman -S --needed - <<< "$official_pkgs"
    else
        echo "No Arch-only official packages listed, skipping"
    fi

    echo "Installing yay"
    if ! command -v yay &> /dev/null; then
        sudo pacman -S --needed base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay

        # This is a workaround to fix the issue with yay not being able to resolve DNS
        # https://github.com/Jguer/yay/issues/1400
        sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
        makepkg -si --noconfirm
        cd -
        rm -rf /tmp/yay
    else
        echo "yay already installed"
    fi
    echo "Installing yay packages"
    yay -S --needed - < aurlist.txt
fi

echo "setting zsh as default shell"
chsh -s $(which zsh)

echo "installing oh-my-zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "oh-my-zsh installed"
else
    echo "oh-my-zsh already installed"
fi

echo "installing herdr plugins"
if ! command -v herdr &> /dev/null; then
    echo "herdr not installed, skipping herdr plugins"
else
    installed_plugins="$(herdr plugin list 2>/dev/null || true)"
    while read -r spec _rest; do
        [[ -z "$spec" || "$spec" == \#* ]] && continue

        repo="${spec%%@*}"
        ref=""
        [[ "$spec" == *@* ]] && ref="${spec#*@}"

        if grep -qi "github:$repo@" <<< "$installed_plugins"; then
            echo "$repo already installed"
            continue
        fi

        # A single unavailable plugin repo shouldn't abort the whole bootstrap
        if [[ -n "$ref" ]]; then
            herdr plugin install "$repo" --ref "$ref" -y || echo "failed to install $repo"
        else
            herdr plugin install "$repo" -y || echo "failed to install $repo"
        fi
    done < "$SCRIPT_DIR/packages/herdr-plugins.txt"

    # Local plugins are tracked in the repo, but herdr only knows a plugin once it's
    # linked, and its registry (plugins.json) is gitignored.
    for manifest in "$SCRIPT_DIR"/configs/common/.config/herdr/local-plugins/*/herdr-plugin.toml; do
        [[ -f "$manifest" ]] || continue
        plugin_dir="$(dirname "$manifest")"
        plugin_id="$(sed -nE 's/^id[[:space:]]*=[[:space:]]*"([^"]+)".*/\1/p' "$manifest" | head -1)"

        if grep -qF -- "- $plugin_id (" <<< "$installed_plugins"; then
            echo "$plugin_id already linked"
            continue
        fi

        herdr plugin link "$plugin_dir" || echo "failed to link $plugin_dir"
    done
fi

echo "rebuilding bat cache"
bat cache --build

echo "done"
