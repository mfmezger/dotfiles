# arch based systems
sudo pacman -Syyu

sudo pacman -Sy zsh kitty stow atuin eza zoxide docker docker-compose btop bat discord onefetch fastfetch neovim  obsidian 
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
yay -S --noconfirm zsh-theme-powerlevel10k-git
sudo pacman -S github-cli
# Enableling the docker service on system start.
sudo systemctl start docker.service
sudo systemctl enable docker.service

sudo usermod -aG docker $USER
yay -S visual-studio-code-bin
yay -Sy brave-bin

