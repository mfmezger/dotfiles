# GNU Stow Usage

This repo uses [GNU Stow](https://www.gnu.org/software/stow/) to manage symlinks from the package directories in this repository into your home directory.

## Common Packages

| Package | Creates Symlinks |
| ------- | ---------------- |
| `zsh` | `~/.zshrc`, `~/.p10k.zsh` |
| `git` | `~/.gitconfig` |
| `nvim` | `~/.config/nvim` |
| `ghostty` | `~/.config/ghostty` |
| `zellij` | `~/.config/zellij` |
| `ekphos` | `~/.config/ekphos` |
| `yazi` | `~/.config/yazi` |
| `zed` | `~/.config/zed` |
| `dunst` | `~/.config/dunst` |
| `hypr` | `~/.config/hypr` |
| `waybar` | `~/.config/waybar` |
| `rofi` | `~/.config/rofi` |
| `gtk` | `~/.config/gtk-3.0`, `~/.gtkrc-2.0` |
| `screenlayout` | `~/.screenlayout` |

## Apply Configs

Run `stow` from the repo root:

```bash
cd ~/dotfiles
```

### macOS

```bash
stow zsh git nvim ghostty zellij ekphos yazi zed
```

### Arch Linux / CachyOS

```bash
stow zsh nvim yazi zellij git ghostty ekphos zed dunst hypr waybar rofi gtk
```

### Ubuntu (minimal)

```bash
stow zsh git nvim zellij ekphos
```

## Useful Commands

### Dry run

Preview changes before creating symlinks:

```bash
stow -n zsh
```

### Remove symlinks

Unstow a package:

```bash
stow -D zsh
```

### Restow

Refresh symlinks after adding or moving files in a package:

```bash
stow -R zsh
```

## Troubleshooting Conflicts

If Stow reports a conflict, a target file probably already exists and is not a symlink managed by Stow.

Example:

```bash
mv ~/.zshrc ~/.zshrc.backup
mv ~/.gitconfig ~/.gitconfig.backup

stow zsh git
```

## Practical Tips

- Run `stow` from `~/dotfiles`.
- Start with a dry run when applying a package for the first time.
- Use `stow -R <package>` after adding new files to an existing package.
- If something conflicts, back it up before stowing.
- Apply packages in small batches if you're debugging a setup issue.

## Related Docs

- [README.md](../README.md)
- [shortcuts.md](shortcuts.md)
