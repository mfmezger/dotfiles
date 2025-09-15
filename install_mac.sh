
echo ">>>Installing homebrew <<<"
# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo ">>>Installing brew packages.<<<"
# install brew dependencies
brew bundle --file=~/.dotfiles/Brewfile

echo ">>>Installing Powerlevel10k <<<"
# install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

echo ">>> Linking the files <<<"
stow zsh nvim kitty yazi

echo ">>>Installing Python. <<<"
curl -LsSf https://astral.sh/uv/install.sh | sh


echo ">>>Installing Oh my Zsh! <<<"

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo ">>>Installation succesful completed! <<<"
