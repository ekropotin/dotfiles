# Dotfiles

Configuration files for macOS and Arch Linux.

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

## Linux-specific notes

### NVIDIA GPU

The NVIDIA driver is not managed by pacman and must be installed manually from [nvidia.com](https://www.nvidia.com/drivers).

After installing the driver, enable kernel mode setting by adding `nvidia-drm.modeset=1` to the kernel parameters in `/boot/loader/entries/arch.conf`:

```
options root=UUID=<your-uuid> rw nvidia-drm.modeset=1
```

#### External monitor hotplug

Due to a known wlroots + NVIDIA hybrid graphics limitation, external monitors are not detected on hotplug. After plugging in a monitor, briefly close and open the laptop lid to trigger display re-detection.

### Boot loader

This setup uses **systemd-boot**, not GRUB. The boot entry at `/boot/loader/entries/arch.conf` is machine-specific (root partition UUID) and is not tracked in this repo.
