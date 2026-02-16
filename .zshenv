#
# .zshenv - Environment variables for all zsh sessions
#

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
export PATH=$XDG_BIN_HOME:$PATH

#
# mise
#
mise_path=${XDG_BIN_HOME}/mise
if [ -s ${mise_path} ]; then
  eval "$(${mise_path} activate zsh)"
fi

# For llvm
export PATH=/usr/local/opt/llvm/bin:$PATH

#
# Remove Duplicated Environments
#
typeset -gU PATH
typeset -gU LD_LIBRARY_PATH
