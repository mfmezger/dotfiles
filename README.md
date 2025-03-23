# Dotfiles

# Installation

## Installation on Mac
```bash
# install git
xcode-select --install
git clone https://github.com/mfmezger/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

## Installation of programs and packages
Install the selected environment on Mac:
```
sh install_mac.sh
```



Manually apply with stow:

```
stow zsh nvim kitty yazi git
```



ZSH Autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


https://github.com/maxhu08/dotfiles

https://nygaard.dev/blog/macos-dotfiles
