# Dotfiles

These are my dotfiles for macos and arch with i3.

- [Dotfiles](#dotfiles)
- [Installation](#installation)
  - [Prerequisites on Mac](#prerequisites-on-mac)
  - [Installation of programs and packages](#installation-of-programs-and-packages)
    - [Install the selected environment on Mac](#install-the-selected-environment-on-mac)
    - [Install the selected environment on Arch with i3.](#install-the-selected-environment-on-arch-with-i3)


# Installation

## Prerequisites on Mac
```bash
# install git
xcode-select --install
git clone https://github.com/mfmezger/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

## Installation of programs and packages

### Install the selected environment on Mac
```
sh install_mac.sh
```

Manually apply with stow:

```
stow zsh nvim kitty yazi git
```

### Install the selected environment on Arch with i3.
```
sh install_linux.sh
```

Manually apply with stow:

```
stow zsh nvim kitty yazi git i3 screenlayout
```



