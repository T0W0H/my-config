# Dotfiles — twh's Development Environment

Managed via bare Git repository at `~/dotfiles.git`.  
17 tracked files | 3 commits | Last updated 2026-06-01

---

## Quick Reference

```bash
# Everyday usage (alias defined in .zshrc / .bashrc)
dotfiles status          #  what changed?
dotfiles add <file>      #  stage a file
dotfiles commit -m ".."   #  save changes
dotfiles log --oneline    #  view history
dotfiles diff             #  see unstaged changes

# Restore from scratch
git clone ~/dotfiles.git ~/dotfiles-restore
cp -a ~/dotfiles-restore/.vimrc ~/
cp -ar ~/dotfiles-restore/.config/. ~/.config/
#  dconf terminal profiles
dconf load /org/gnome/terminal/legacy/profiles:/ < ~/.config/dconf-dump/gnome-terminal-profiles.conf
```

---

## Tracked Files

### Vim — `~/.vimrc`

Complete ROS development workflow:

| Feature | Key | Details |
|---------|-----|---------|
| File search | `\f` | FZF file finder |
| Grep | `\g` | Ripgrep search |
| Buffers | `\b` | Buffer list |
| File browser (tmux) | `Ctrl-N` | Opens Yazi in tmux split at current file's directory |
| File browser (no tmux) | `Ctrl-N` | NERDTree toggle |
| LSP definition | `gd` | Go to definition (clangd / pyright-langserver) |
| LSP hover | `K` | Show type / docs |
| LSP references | `gr` | Find references |
| LSP rename | `F2` | Rename symbol |
| LSP diagnostics | `[g` `]g` | Jump between errors |
| Build current pkg | `\m` | catkin build --this |
| Build all | `\ma` | catkin build entire workspace |
| Terminal (tmux) | `\ts` | New shell pane at file dir |
| Terminal (no tmux) | `\ts` | Vim :terminal |
| roslaunch | `\tr` | Launch current .launch file |
| New pane | `\tv` | Vertical tmux split |
| rosrun | `\to` | Run a specific ROS node |
| Toggle whitespace | `\l` | Show/hide trailing spaces |
| Snippet expand | `Tab` | snipMate snippet trigger |
| Snippet jump | `Ctrl-j/k` | Next/previous placeholder |

**Theme**: Scarlet (terminal ANSI colors synced with GNOME Terminal / tmux / Yazi).  
**LSP servers**: clangd-18 (apt) for C++, pyright-langserver (pip) for Python.  
**Format on save**: autopep8 (Python), clang-format Google style (C++), json.tool (JSON), xmllint (ROS .launch).  
**Plugins** (in `~/.vim/pack/plugins/start/`): fzf.vim, nerdtree, vim-lsp, vim-polyglot, vim-ros, vim-snippets.  
**Snippet engine**: snipMate from apt (`vim-snipmate`), snippets from `vim-snippets` plugin.

### tmux — `~/.tmux.conf.local`

Oh My Tmux! configuration with Scarlet color palette.  
Key settings:
- `tmux_conf_24b_colour=true` — truecolor support
- Pane borders / status bar synced to Scarlet theme
- `tmux_conf_new_pane_retain_current_path=true` — new panes keep CWD

### Yazi — `~/.config/yazi/`

| File | Purpose |
|------|---------|
| `yazi.toml` | File opener — uses `yazi-vim-opener` (tmux-aware, sends files to existing Vim server) |
| `keymap.toml` | Default keybindings, no custom overrides |
| `theme.toml` | Scarlet color scheme synced with terminal/tmux/Vim |

### Shell — `~/.zshrc`, `~/.bashrc`

- Oh My Zsh with plugins: `git ros colored-man-pages jsontools zsh-autosuggestions zsh-syntax-highlighting zsh-completions`
- Powerlevel10k prompt (`~/.p10k.zsh`, not tracked — regenerated on first run)
- `dotfiles` alias for managing this repo
- ROS Noetic sourced automatically
- `bw` alias → opens `~/Documents/note.txt`

### Desktop Environment

| File | Purpose |
|------|---------|
| `~/.pam_environment` | Sets `LANG=en_US.UTF-8` for all sessions |
| `~/.config/user-dirs.dirs` | XDG directories mapped to English names |
| `~/.config/user-dirs.locale` | `en_US` — prevents Nautilus from showing Chinese dir names |
| `~/.config/gtk-3.0/settings.ini` | `gtk-application-prefer-dark-theme=0` |

### GNOME Terminal — `~/.config/dconf-dump/`

Exported dconf dump of terminal profile configuration.  
Contains the **Scarlet** palette and profile UUID `8a2af8cc-a024-4ca0-850d-b545e3b48ae1` ("我的最爱").  
Restore with: `dconf load /org/gnome/terminal/legacy/profiles:/ < gnome-terminal-profiles.conf`

### Custom Scripts — `~/.local/bin/yazi-vim-opener`

```bash
#!/bin/bash
# yazi → vim opener. Detects tmux and uses --remote-silent when inside tmux.
if [ -n "$TMUX" ]; then
    exec vim --servername VIM --remote-silent "$@"
else
    exec vim "$@"
fi
```

### System Reference — `~/.config/dotfiles/locale.conf`

Copy of `/etc/default/locale` — `LANG=en_US.UTF-8`.  
To restore: `sudo cp ~/.config/dotfiles/locale.conf /etc/default/locale`

---

## Theme: Scarlet

Warm, red/magenta-dominant palette on pure black `#000000`.

| ANSI | Hex | Role |
|------|-----|------|
| 0 | `#000000` | Pure black background |
| 1 | `#ff5252` | Coral red — errors / strings |
| 2 | `#69f0ae` | Mint green — success / builtins |
| 3 | `#ffab40` | Amber — warnings / numbers |
| 4 | `#448aff` | Blue — directory names (restrained) |
| **5** | **`#ff4081`** | **Hot pink / magenta — THE accent color** |
| 6 | `#40c4ff` | Light cyan — types / links |
| 7 | `#cfd8dc` | Light gray — body text |
| 8–15 | bright variants | UI highlights |

The palette is synced across all four layers:
```
GNOME Terminal dconf → tmux colours → Vim g:terminal_ansi_colors → Yazi theme.toml
```

---

## System Language (en_US.UTF-8)

| What | Where | Value |
|------|-------|-------|
| System locale | `/etc/default/locale` | `LANG=en_US.UTF-8` |
| User PAM | `~/.pam_environment` | `LANG DEFAULT=en_US.UTF-8` |
| XDG locale | `~/.config/user-dirs.locale` | `en_US` |

### Chinese → English Directory Migration

All 8 XDG directories were renamed and symlinks created for backward compatibility:

```
  桌面   → Desktop    (symlink: 桌面 → Desktop)
  下载   → Downloads  (symlink: 下载 → Downloads)
  模板   → Templates  (symlink: 模板 → Templates)
  公共的  → Public     (symlink: 公共的 → Public)
  文档   → Documents  (symlink: 文档 → Documents)
  音乐   → Music      (symlink: 音乐 → Music)
  图片   → Pictures   (symlink: 图片 → Pictures)
  视频   → Videos     (symlink: 视频 → Videos)
  我的东西 → my-stuff  (symlink: 我的东西 → my-stuff)
```

Old scripts using `$HOME/下载` or `~/文档/` continue to work via symlinks.  
New code should use English paths like `$HOME/Downloads` or `~/Documents/`.

---

## Dependencies (what to install on a fresh machine)

### apt packages
```bash
sudo apt install -y \
  vim-gtk3 vim-snipmate tmux zsh \
  clangd-18 clang-format fzf fd-find ripgrep \
  python3-pip python3-autopep8 \
  fonts-firacode fonts-powerline \
  xclip p7zip-full zip unzip \
  cmake build-essential g++
```

### pip (--user)
```bash
pip3 install --user \
  python-lsp-server pylsp-rope rope \
  black ruff autopep8 \
  catkin-tools osrf-pycommon \
  numpy scipy pandas scikit-learn open3d \
  pyyaml requests tqdm pillow
```

### Source-built tools (already at /usr/local/)
| Tool | Version | Binary |
|------|---------|--------|
| Vim | 9.2 | `/usr/local/bin/vim` |
| chafa | 1.16.0 | `/usr/local/bin/chafa` |
| ueberzugpp | 2.9.10 | `/usr/local/bin/ueberzugpp` |

### ROS (already at /opt/ros/noetic/)
```bash
# Source in .zshrc
source /opt/ros/noetic/setup.zsh
source ~/catkin_ws/devel/setup.zsh
```

---

## File Permissions & Security

- `~/.ssh/` is **not** tracked (excluded by gitignore)
- No API keys or secrets in tracked files (HAPPYAPI_API_KEY was removed from `.zshrc` on 2026-06-01)
- `~/.gitconfig` is tracked but does not contain credentials

---

## Gitignore Pattern (what is NOT tracked)

```
# Sensitive
*.key *.pem *secret* *API_KEY*

# Shell history
.bash_history .zsh_history .python_history

# Caches
.cache/ *.zwc .zcompdump*

# Binary / build artifacts
*.o *.a *.so node_modules/

# Application data
.config/google-chrome/ .config/DingTalk/ .config/VSCodium/
.mozilla/ .xwechat/ .npm/ .nvm/ .opencode/

# SSH / GPG
.ssh/ .gnupg/

# ROS logs, Gazebo
.ros/log/ .gazebo/ .ignition/ .sdformat/

# Trash
.local/share/Trash/
```

---

## Complete Restore (blank machine → working environment)

```bash
# 1. Clone this repo
git clone ~/dotfiles.git ~/dotfiles-restore

# 2. Copy all dotfiles into place
cp ~/dotfiles-restore/.vimrc ~/
cp ~/dotfiles-restore/.tmux.conf.local ~/
cp ~/dotfiles-restore/.zshrc ~/
cp ~/dotfiles-restore/.bashrc ~/
cp ~/dotfiles-restore/.pam_environment ~/
cp ~/dotfiles-restore/.gitconfig ~/
cp -r ~/dotfiles-restore/.config ~/

# 3. Restore GNOME Terminal profiles
dconf load /org/gnome/terminal/legacy/profiles:/ < ~/.config/dconf-dump/gnome-terminal-profiles.conf

# 4. Restore system locale (requires sudo)
sudo cp ~/.config/dotfiles/locale.conf /etc/default/locale

# 5. Recreate Chinese→English directory symlinks (if migrating from Chinese system)
cd ~
# Only needed if the Chinese-named dirs exist or need recreating:
for pair in "桌面:Desktop" "下载:Downloads" "模板:Templates" "公共的:Public" "文档:Documents" "音乐:Music" "图片:Pictures" "视频:Videos"; do
  cn="${pair%%:*}" en="${pair##*:}"
  [ -d "$en" ] || mkdir -p "$en"
  [ ! -e "$cn" ] && ln -s "$en" "$cn"
done

# 6. Install Vim plugins (if not copied)
mkdir -p ~/.vim/pack/plugins/start
# Clone/install: fzf.vim, nerdtree, vim-lsp, vim-polyglot, vim-ros, vim-snippets

# 7. Re-login for locale changes to take effect
```

---

## Commit History

```
b119c4f Add README and system locale reference
911bc4f Add Yazi Scarlet configs + dotfiles alias in shellrc
75b4949 Initial dotfiles — Scarlet theme, ROS dev workflow, locale en_US
```
