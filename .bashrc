# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    # We have color support; assume it's compliant with Ecma-48
    # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    # a case would tend to support setf rather than setaf.)
    color_prompt=yes
  else
    color_prompt=
  fi
fi

if [ "$color_prompt" = yes ]; then
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
  ;;
*)
  ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  #alias dir='dir --color=auto'
  #alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# ======================= 完美修复：无乱码、分支变色、紫色 $ =======================
# 1. 只获取分支名，不处理颜色
git_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# 2. 判断 Git 是否有修改

git_dirty() {
  local git_dir
  git_dir="$(git rev-parse --git-dir 2>/dev/null)" || return 1

  local cache_file="$git_dir/.prompt_dirty_cache"
  local repo_root
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null)"

  # 如果缓存文件存在且目录相同且不超过 2 秒，则直接使用缓存
  if [ -f "$cache_file" ]; then
    local cache_age
    cache_age=$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || stat -f %m "$cache_file" 2>/dev/null)))
    if [ "$cache_age" -lt 2 ]; then
      local cached_root
      read -r cached_root <"$cache_file"
      if [ "$cached_root" = "$repo_root" ]; then
        # 缓存有效，直接输出有修改（因为我们是 dirty 时才写，干净时不写）
        return 0
      fi
    fi
  fi

  # 实际检查
  if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
    # 记录为 dirty，保存 repo_root 以便比对
    echo "$repo_root" >"$cache_file"
    return 0
  else
    # 干净，删除缓存文件（表示干净）
    rm -f "$cache_file"
    return 1
  fi
}

# 3. 把颜色逻辑直接写在 PS1 里，彻底避免乱码

export PS1="\[\033[01;34m\]\w\[\033[00m\]\$(if [ -n \"\$(git_branch)\" ]; then \
  if git_dirty; then \
    printf '%s' \" \[\033[01;31m\](\$(git_branch))\[\033[00m\]\"; \
  else \
    printf '%s' \" \[\033[01;32m\](\$(git_branch))\[\033[00m\]\"; \
  fi; \
fi) \[\033[35m\]\$\[\033[00m\] "

source /opt/ros/noetic/setup.bash
source ~/catkin_ws/devel/setup.bash
alias bw='vim ~/Documents/note.txt'
alias sslvpn='sudo /opt/sslvpnclient/secgateaccess'
# 自定义命令：一键清理 VPN 残留并快速连接
xdl() {
  echo ">>> 清理旧进程和残留文件..."
  sudo pkill secgateaccess
  sudo rm -f /opt/sslvpnclient/runtime/sslvpn.pid
  sudo rm -f /tmp/.sslvpn*

  echo ">>> 启动 VPN 连接..."
  sslvpn quickconnect

  echo ">>> VPN 状态信息..."
  sslvpn showinfo
}

# 自定义指令，开启南科大标注工具
bz() {
  cd ~/bz/SUSTechPOINTS_hu && ~/bz/SUSTechPOINTS_hu/venv/bin/python main.py
}

# 动态更新终端标题为用户@主机: 当前目录
PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"'
