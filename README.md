# Dotfiles
Configuration files for pleasant developer experience with OSX

# Installation
Below are instructions for installation from scratch on a brand new machine.

1. Homebrew

```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"```

2.  oh-my-zsh
```sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"```

3. Install git and clone the repository

```
brew install git
git clone git@github.com:ekropotin/dotfiles.git
cd dotfiles
```

4. Install software from Brewfile
```brew bundle```

5. Install configs
```
chmod +x link.sh && ./link.sh
```
This script will create symbolic links in your home folder to all dotfiles in the repository.
