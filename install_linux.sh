# arch based systems
sudo pacman -Syyu

sudo pacman -Sy zsh kitty stow atuin eza zoxide docker docker-compose btop bat discord onefetch fastfetch neovim  obsidian dust tokei git-delta ttf-cascadia-code-nerd ttf-cascadia-mono-nerd xautolock
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
yay -S --noconfirm zsh-theme-powerlevel10k-git
sudo pacman -Sy github-cli ghostty
sudo pacman -S clamav
# Enableling the docker service on system start.
sudo systemctl start docker.service
sudo systemctl enable docker.service

sudo usermod -aG docker $USER
yay -S visual-studio-code-bin
yay -Sy brave-bin
yay -S --noconfirm zsh-abbr

# Install zsh-autosuggestions-abbreviations-strategy
if [ ! -d "$HOME/.local/share/zsh-autosuggestions-abbreviations-strategy" ]; then
    git clone https://github.com/olets/zsh-autosuggestions-abbreviations-strategy.git "$HOME/.local/share/zsh-autosuggestions-abbreviations-strategy"
fi

# update virus database
sudo freshclam

# Real-time monitoring setup
sudo systemctl enable clamav-freshclam


# Firewall
sudo pacman -S ufw
sudo systemctl enable ufw.service
sudo systemctl start ufw.service

# Basic configuration
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable

# Application Firewall - OpenSnitch
sudo pacman -S opensnitch
sudo systemctl enable --now opensnitchd

echo ">>> Linking the dotfiles <<<"
stow zsh nvim kitty yazi git i3 screenlayout

echo ">>>Installation successful completed! <<<"
