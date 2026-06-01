# Dotfiles — twh's configuration

Managed via bare git repo at `~/dotfiles.git`.

## Usage
```
dotfiles status
dotfiles add <file>
dotfiles commit -m "message"
dotfiles log
dotfiles diff
```

## Contents

| Scope | Files |
|-------|-------|
| Vim | `.vimrc` |
| tmux | `.tmux.conf.local` |
| Yazi | `.config/yazi/yazi.toml`, `keymap.toml`, `theme.toml` |
| Shell | `.zshrc`, `.bashrc` |
| Desktop | `.pam_environment`, `.config/user-dirs.dirs`, `.config/user-dirs.locale`, `.config/gtk-3.0/settings.ini` |
| GNOME Terminal | `.config/dconf-dump/gnome-terminal-profiles.conf` |
| Scripts | `.local/bin/yazi-vim-opener` |
| System ref | `.config/dotfiles/locale.conf` (from /etc/default/locale) |

## Theme: Scarlet
Warm, red/magenta-dominant palette on pure black `#000000`. Synced across terminal, tmux, Vim `:terminal`, and Yazi.

## Restore
```bash
git clone ~/dotfiles.git ~/dotfiles-restore
# Then symlink or copy files into place
```
