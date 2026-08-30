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

echo "installing powerlevel10k"
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    echo "powerlevel10k installed"
else
    echo "powerlevel10k already installed"
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
fi

echo "rebuilding bat cache"
bat cache --build

echo "done"
