#
# Shell Variables
#
SAVEHIST=100000
HISTSIZE=100000
HISTFILE=$HOME/.zhistory


#
# Language Settings
#
export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8

# export LANGUAGE=ja_JP.UTF-8
# export LC_ALL=ja_JP.UTF-8
# export LC_CTYPE=ja_JP.UTF-8
# export LANG=ja_JP.UTF-8


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
# XDG Base Directory 
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
#
export XDG_BIN_HOME=$HOME/.local/bin
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_LIB_HOME=$HOME/.local/lib
export XDG_STATE_HOME=$HOME/.local/state


#
# Path
#
export PATH=$HOME/.local/bin:$PATH


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
# rtx
# https://github.com/jdx/rtx
#
rtx_path=$XDG_DATA_HOME/rtx
if [ -e $rtx_path ]; then
  eval "$($rtx_path/bin/rtx activate zsh)"
fi


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
fbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}

# fbr - checkout git branch (including remote branches)
fbr() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fbr - checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
fbr() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# fco - checkout git branch/tag
fco() {
  local tags branches target
  tags=$(
    git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") |
    fzf-tmux -l30 -- --no-hscroll --ansi +m -d "\t" -n 2) || return
  git checkout $(echo "$target" | awk '{print $2}')
}


# fco_preview - checkout git branch/tag, with a preview showing the commits between the tag/branch and HEAD
fco_preview() {
  local tags branches target
  tags=$(
git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
git branch --all | grep -v HEAD |
sed "s/.* //" | sed "s#remotes/[^/]*/##" |
sort -u | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
(echo "$tags"; echo "$branches") |
    fzf --no-hscroll --no-multi --delimiter="\t" -n 2 \
        --ansi --preview="git log -200 --pretty=format:%s $(echo {+2..} |  sed 's/$/../' )" ) || return
  git checkout $(echo "$target" | awk '{print $2}')
}
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
  eval "$(direnv hook bash)"
fi

# frepo - ghq cd browser
ghq-fzf() {
  local dir
  dir=$(ghq list > /dev/null | fzf-tmux --reverse +m) &&
    cd $(ghq root)/$dir
}
# zle -N ghq-fzf
bindkey "^]" ghq-fzf


# For llvm
export PATH=/usr/local/opt/llvm/bin:$PATH

#
# Remove Duplicated Environments
#
typeset -gU PATH
typeset -gU LD_LIBRARY_PATH

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
