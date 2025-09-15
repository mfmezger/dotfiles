# 🔧 Dotfiles

Cross-platform dotfiles for macOS and Arch Linux with i3, featuring modern CLI tools and a clean development environment.

## 🖥️ **What's Included**

### **Core Applications**
- **Shell**: Zsh with Oh My Zsh + Powerlevel10k theme
- **Terminal**: Ghostty (primary), Kitty (Linux), iTerm2 (macOS)
- **Editor**: Neovim with modern configuration
- **File Manager**: Yazi (terminal-based)
- **Version Control**: Git with Delta for better diffs

### **Modern CLI Tools**
- `eza` - Better ls with icons and colors
- `bat` - Better cat with syntax highlighting
- `zoxide` - Smart cd with frecency
- `atuin` - Better shell history
- `fastfetch` - System information
- `btop` - Modern system monitor
- `git-delta` - Beautiful git diffs

### **Development Tools**
- Docker & Docker Compose
- Kubernetes (kubectl, helm)
- GitHub CLI
- Python (UV for package management)
- Pre-commit hooks

## 🚀 **Installation**

### **Prerequisites**

#### macOS
```bash
# Install Xcode command line tools
xcode-select --install

# Clone the repository
git clone https://github.com/mfmezger/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

#### Arch Linux
```bash
# Clone the repository
git clone https://github.com/mfmezger/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
```

### **Automated Installation**

#### macOS
```bash
sh install_mac.sh
```
This installs:
- Homebrew + all packages from Brewfile
- Oh My Zsh + Powerlevel10k theme
- UV for Python management
- Links all dotfiles with stow

#### Arch Linux with i3
```bash
sh install_linux.sh
```
This installs:
- All packages via pacman/yay
- Security tools (ClamAV, UFW, OpenSnitch)
- Docker setup with user permissions
- Links all dotfiles with stow

### **Manual Installation** 
If you prefer to link dotfiles manually:

```bash
# macOS
stow zsh nvim kitty yazi git

# Arch Linux
stow zsh nvim kitty yazi git i3 screenlayout
```

## ⚙️ **Features**

### **Cross-Platform Compatibility**
- Platform-specific plugins and aliases
- Conditional loading based on OS detection
- Different terminal setups per platform

### **Smart Directory Navigation**
- `cd` is aliased to zoxide for smart jumping
- Yazi integration with `yy` function
- Enhanced history with atuin

### **Git Workflow**
- Delta for beautiful diffs
- Helpful aliases (`gs`, `gg`, `gp`, etc.)
- Pre-commit hooks integration

### **Update Management**
- `uu` alias updates everything on your platform
- macOS: brew packages + cask upgrades
- Arch: pacman + yay + security updates

## 🎨 **Customization**

The configuration is designed to be both functional and aesthetically pleasing:
- Nerd Font icons throughout
- Consistent color schemes
- Modern terminal experience
- Vim-style navigation where possible

## 📁 **Structure**

```
~/.dotfiles/
├── zsh/           # Zsh configuration with Oh My Zsh
├── nvim/          # Neovim configuration
├── kitty/         # Kitty terminal config
├── ghostty/       # Ghostty terminal config
├── git/           # Git configuration with delta
├── yazi/          # Yazi file manager config
├── i3/            # i3 window manager (Linux only)
├── screenlayout/  # Display layout scripts (Linux only)
├── Brewfile       # macOS package definitions
├── install_mac.sh # macOS installation script
└── install_linux.sh # Arch Linux installation script
```

## 🐛 **Troubleshooting**

- Make sure stow is installed before running install scripts
- On macOS, ensure Homebrew is properly set up
- On Arch, make sure yay AUR helper is installed
- Restart your terminal after installation for changes to take effect

