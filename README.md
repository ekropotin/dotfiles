# Dotfiles

Configuration files for pleasant developer experience with OSX

## Installation

Below are instructions for installation from scratch on a brand new machine.

1. Clone the repo

```bash
git clone git@github.com:ekropotin/dotfiles.git
cd dotfiles
```

2. Install software
```bash
./install_packages.sh
```

3. Link config files
```bash
./setup_dotfiles.sh
```

After starting tmux session, don't forget to install tpm plugins by pressing `ctrl + shift + I`

If you are using iTerm 2/3 as a terminal emulator, you need to enable `Applications in terminal may access clipboard` in it's settings in order to copy the content from Tmux into the system clipboard.
