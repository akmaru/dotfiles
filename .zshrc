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
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
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
# Plugins
#

## fzf
case $OSTYPE in
  linux*)
    source $HOME/.config/fzf/fzf.zsh
    ;;
esac



#
# Complementarity
#
autoload -Uz compinit && compinit
compctl -c man which
compctl -g '*.tex' platex jlatex
compctl -g '*.dvi' xdvi dvi2ps
compctl -g '*.ps' gv lpr idraw


# enhanced
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
# zplug
#
# export ZPLUG_HOME=$(brew --prefix)/opt/zplug
# source $ZPLUG_HOME/init.zsh
# # source $HOME/.zplug/init.zsh

# # Plugins
# zplug 'romkatv/powerlevel10k', as:theme, depth:1
# zplug 'zsh-users/zsh-autosuggestions'
# zplug 'zsh-users/zsh-completions'
# zplug "zsh-users/zsh-history-substring-search"
# zplug 'zsh-users/zsh-syntax-highlighting'
# zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf
# zplug "junegunn/fzf", as:command, use:bin/fzf-tmux
# zplug "b4b4r07/enhancd", use:init.sh
# zplug 'mafredri/zsh-async', from:github
# zplug "chrissicool/zsh-256color"
# zplug 'mollifier/anyframe'
# zplug 'felixr/docker-zsh-completion'

# # Interactive Install Plugin
# if ! zplug check --verbose; then
#     printf "Install? [y/N]: "
#     if read -q; then
#         echo; zplug install
#     fi
# fi

# # Load Plugins
# zplug load

# fzf
export FZF_TMUX=1
export FZF_DEFAULT_OPTS='--height 40% --reverse --border'
#source $HOME/.zplug/repos/junegunn/fzf/shell/key-bindings.zsh

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
eval "$(direnv hook bash)"

# frepo - ghq cd browser
ghq-fzf() {
  local dir
  dir=$(ghq list > /dev/null | fzf-tmux --reverse +m) &&
    cd $(ghq root)/$dir
}
# zle -N ghq-fzf
bindkey "^]" ghq-fzf


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# For llvm
export PATH=/usr/local/opt/llvm/bin:$PATH


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


# For nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# For pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PATH"

#
# Remove Duplicated Environments
#
typeset -gU PATH
typeset -gU LD_LIBRARY_PATH

# eval "$(/Users/maru/.local/share/rtx/bin/rtx activate zsh)"

[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh
