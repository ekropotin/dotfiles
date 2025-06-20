#!/bin/bash

set -e

echo "linking tools to /usr/local/bin"
if [[ ! -e /usr/local/bin/tms ]]; then
    sudo ln -s $PWD/tools/tms /usr/local/bin
    echo "linked tms"
else
    echo "tms already linked"
fi

if [[ ! -e /usr/local/bin/cht ]]; then
    sudo ln -s $PWD/tools/cht /usr/local/bin
    echo "linked cht"
else
    echo "cht already linked"
fi

echo "installing oh-my-zsh"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "oh-my-zsh installed"
else
    echo "oh-my-zsh already installed"
fi

echo "installing tmux plugin manager"
if [[ ! -d "$HOME/.config/tmux/plugins/tpm" ]]; then
    git clone https://github.com/tmux-plugins/tpm $HOME/.config/tmux/plugins/tpm
    echo "tmux plugin manager installed"
else
    echo "tmux plugin manager already installed"
fi

echo "installing powerlevel10k"
if [[ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    echo "powerlevel10k installed"
else
    echo "powerlevel10k already installed"
fi

# Detect OS and install appropriate package manager
OS=$(uname -s)

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
    echo "Installing brew packages"
    brew bundle
fi

# Handle Arch Linux
if [[ "$OS" == "Linux" ]] && ([[ -f /etc/arch-release ]] || command -v pacman &> /dev/null); then
    echo "Detected Arch Linux"

    echo "Installing official packages"
    sudo pacman -S --needed - < pkglist.txt

    echo "Installing yay"
    if ! command -v yay &> /dev/null; then
        sudo pacman -S --needed base-devel
        git clone https://aur.archlinux.org/yay.git /tmp/yay
        cd /tmp/yay

        # This is a workaround to fix the issue with yay not being able to resolve DNS
        # https://github.com/Jguer/yay/issues/1400
        ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
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

echo "rebuilding bat cache"
bat cache --build

echo "done"
