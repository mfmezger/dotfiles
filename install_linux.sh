# arch based systems
sudo pacman -Syyu

sudo pacman -S zsh kitty stow atuin eza zoxide docker docker-compose btop bat 

# Enableling the docker service on system start.
sudo systemctl start docker.service
sudo systemctl enable docker.service

sudo usermod -aG docker $USER
yay -S visual-studio-code-bin


