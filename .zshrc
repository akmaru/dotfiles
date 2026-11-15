#
# Shell Variables
#
SAVEHIST=100000
HISTSIZE=100000
HISTFILE=$HOME/.zhistory


#
# Module import (load ~/.config/zsh/<name>.zsh)
#
ZSH_CONFIG_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/zsh
import() {
  local name f
  for name in "$@"; do
    f="$ZSH_CONFIG_DIR/$name.zsh"
    if [[ -r $f ]]; then
      source "$f"
    else
      print -u2 "import: module not found: $name ($f)"
    fi
  done
}


#
# Color Settings
#
autoload -Uz colors && colors
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
autoload -Uz is-at-least


#
# Key Bindings
#
bindkey -e
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
# bindkey "^?" backward-delete-char


#
# Options
#
setopt auto_cd
setopt auto_list
setopt auto_menu
setopt auto_pushd
setopt auto_param_keys
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_reduce_blanks
setopt ignore_eof
setopt inc_append_history
setopt list_types
setopt magic_equal_subst
setopt mark_dirs
setopt no_beep
setopt notify
setopt pushd_ignore_dups
setopt share_history

# Append '/' into delimiter
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'



#
# Sheldon
#
if type "sheldon" > /dev/null 2>&1; then
  eval "$(sheldon source)"
fi


#
# Complementarity
# It must be executed after zsh-completions
#
compctl -c man which
compctl -g '*.tex' platex jlatex
compctl -g '*.dvi' xdvi dvi2ps
compctl -g '*.ps' gv lpr idraw


#
# Plugins
#

## powerlevel10l
 [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


## fzf
case $OSTYPE in
  linux*)
    fzf_zsh_path="${XDG_CONFIG_HOME}"/fzf/fzf.zsh
    [ -f "${fzf_zsh_path}" ] && source "${fzf_zsh_path}"
    ;;
esac
export FZF_TMUX=1
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
#source $HOME/.zplug/repos/junegunn/fzf/shell/key-bindings.zsh


## enhanced
export ENHANCD_HOOK_AFTER_CD=ls

#
# Aliases
#

# ls
if type "eza" > /dev/null 2>&1; then
    alias ls='eza'
    alias l='eza -F'
    alias la='eza -a'
    alias ll='eza -l'
else
  case $OSTYPE in
      darwin*)
	  alias ls='ls -FG'
	  ;;
     linux*)
	  alias ls='ls -F --color=auto'
	  ;;
  esac
alias l='ls -lAgs | less -r'
alias la='ls -A'
alias ll='ls -l'
fi

alias emacs='TERM=xterm-256color emacs -nw'
alias egdb='emacs -f gud-gdb'

# ssh with iTerm2 tmux integration
# Usage: ssht [ssh_options...] <host> [session_name]
ssht() {
  local -a ssh_opts=()
  local -a positional=()
  while [[ $# -gt 0 ]]; do
    if [[ "$1" == -* ]]; then
      ssh_opts+=("$1")
      # -o, -L, -R, -D, -J, -i etc. take a separate argument
      if [[ "$1" =~ ^-[oLRDJibceFIlmOpSwW]$ ]]; then
        shift
        ssh_opts+=("$1")
      fi
    else
      positional+=("$1")
    fi
    shift
  done
  local host="${positional[1]}"
  local session="${positional[2]:-main}"
  ssh -t "${ssh_opts[@]}" "$host" tmux -CC new-session -A -s "$session"
}


#
# Functions
#
title () {echo -n "\e]0;$*\a"}
function dmalloc { eval `command dmalloc -b $*`; }


#
# OS local specific settings
#
case $OSTYPE in
    solaris*)
        limit coredumpsize 0
        ;;
    linux*)
        ulimit -c 0
        ;;
    irix*)
        ;;
    cygwin*)
        ;;
esac


#
# fzf functions
#
# fcoc - checkout git commit
fcoc() {
  local commits commit
  commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
  commit=$(echo "$commits" | fzf --tac +s +m -e) &&
  git checkout $(echo "$commit" | sed "s/ .*//")
}
# fshow - git commit browser
fshow() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
  fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
FZF-EOF"
}
if type "direnv" > /dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# frepo - ghq cd browser
ghq-fzf() {
  local dir
  dir=$(ghq list -p | fzf --reverse +m --height=40%)
  if [[ -n $dir ]]; then
    BUFFER="cd ${(q)dir}"
    zle accept-line
  fi
  zle reset-prompt
}
zle -N ghq-fzf
bindkey "^]" ghq-fzf


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


#
# aws
#
import aws

#
# Claude Code: デフォルトのプロファイル（CLAUDE_CONFIG_DIR）
# 会社の環境では dotfiles_fixstars の install がこのファイルを書く。無ければ ~/.claude（個人）が使われる。
#
[ -f ~/.config/claude/profile.env ] && source ~/.config/claude/profile.env
