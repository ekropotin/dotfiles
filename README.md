# Dotfiles

Configuration files for pleasant developer experience with OSX

## Installation

Below are instructions for installation from scratch on a brand new machine.

1. Homebrew

```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"```

2. oh-my-zsh

```sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"```

3. Install git

```brew install git```

4. Clone the repo

```
git clone git@github.com:ekropotin/dotfiles.git
cd dotfiles
```

5. Install software from Brewfile

```brew bundle```

6. Install Tmux Plugin Manager

```shell
git clone https://github.com/tmux-plugins/tpm $HOME/.config/tmux/plugins/tpm
```

7. Install configs

```
chmod +x link.sh && ./link.sh
```
This script will create symbolic links in your home folder to all dotfiles in the repository.

8. Powerlevel10k (zsh theme)
```shell
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
```

After starting tmux session, don't forget to install tpm plugins by pressing `ctrl + shift + I`

If you are using iTerm 2/3 as a terminal emulator, you need to enable `Applications in terminal may access clipboard` in it's settings in order to copy the content from Tmux into the system clipboard.
