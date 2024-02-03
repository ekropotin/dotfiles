# Dotfiles
Configuration files for pleasant developer experience with OSX

# Installation
Below are instructions for installation from scratch on a brand new machine.

1. Homebrew

```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"```

2.  oh-my-zsh

```sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"```

3. Install git

```brew install git```

4. Install tpm

```git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm```

5. Clone the repo

```
git clone git@github.com:ekropotin/dotfiles.git
cd dotfiles
```

6. Install software from Brewfile

```brew bundle```

7. Install configs

```
chmod +x link.sh && ./link.sh
```

This script will create symbolic links in your home folder to all dotfiles in the repository.

If you are using iTerm 2/3 as a terminal emulator, you need to enable `Applications in terminal may access clipboard` in it's settings in order to copy the content from Tmux into the system clipboard. 
