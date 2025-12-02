
echo ">>>Installing homebrew <<<"
# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo ">>> Adding Homebrew to PATH for this session... <<<"
# Check standard install locations and load the environment
if [ -f "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi

echo ">>>Installing brew packages.<<<"
# install brew dependencies
brew bundle --file=~/.dotfiles/Brewfile

echo ">>>Installing Python. <<<"
curl -LsSf https://astral.sh/uv/install.sh | sh

echo ">>>Installing Oh my Zsh! <<<"

# install oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo ">>>Installing Powerlevel10k <<<"
# install powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions


echo ">>> Linking the files <<<"
stow zsh nvim kitty yazi git

echo ">>>Installation succesful completed! <<<"
