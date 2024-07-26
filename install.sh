
echo ">>>Installing homebrew <<<"
# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo ">>>Installing brew packages.<<<"
# install brew dependencies
brew bundle --file=~/.dotfiles/homebrew/.Brewfile

echo ">>>Installing Oh my Zsh! <<<"
# install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo ">>>Installing Powerlevel10k <<<"
# install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k


stow . 

# # install auto suggestion plugin
# git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# for poetry 
# poetry config virtualenvs.in-project true
