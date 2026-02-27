# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Personal dotfiles for macOS and Linux (Arch). Manages shell, editor, terminal, and window manager configurations via symlinks.

## Setup Commands

```bash
./install_packages.sh    # Install software (Homebrew on mac, pacman/yay on Arch), oh-my-zsh, tpm, powerlevel10k
./setup_dotfiles.sh      # Symlink config files from configs/ to $HOME
./editors/bootstrap-editors.sh  # Symlink VSCode/Cursor settings and install extensions
```

## Repository Structure

- `configs/` - Dotfiles organized by platform:
  - `common/` - Cross-platform configs (zsh, p10k, neovim, tmux, kitty, bat, jj, ideavimrc)
  - `mac/` - macOS-specific configs (yabai, skhd)
  - `linux/` - Linux-specific configs (sway, waybar, tofi)
- `packages/` - Package lists: `Brewfile` (macOS), `pkglist.txt` + `aurlist.txt` (Arch)
- `editors/` - VSCode/Cursor shared settings, keybindings, and extensions list
- `tools/` - Custom shell scripts symlinked to `/usr/local/bin`:
  - `tms` - Fuzzy-find git repos under `~/sources` and open/switch tmux sessions
  - `cht` - Query cht.sh cheat sheets via fzf

## How Symlinks Work

`setup_dotfiles.sh` processes `configs/common/` first, then platform-specific configs (`configs/mac/` or `configs/linux/`). It symlinks dotfiles (files starting with `.`) to `$HOME` and directories under `.config/` to `$HOME/.config/`. Existing files are backed up before replacement.

## Neovim Config

Lua-based config using Lazy.nvim as plugin manager. Entry point is `configs/common/.config/nvim/init.lua` which loads `lua/ekropotin/`. Plugin configs live in `after/plugin/`, LSP configs in `after/lsp/`. Formatting is handled by StyLua (`stylua.toml` in the nvim root).

## Version Control

This repo uses jj (Jujutsu) colocated with git. The jj config is at `configs/common/.config/jj/config.toml`.
