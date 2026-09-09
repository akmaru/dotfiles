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

# For llvm (Homebrew prefix; absent on Linux and on Apple Silicon)
[ -d /usr/local/opt/llvm/bin ] && export PATH=/usr/local/opt/llvm/bin:$PATH

#
# Remove Duplicated Environments
#
typeset -gU PATH
typeset -gU LD_LIBRARY_PATH

#
# Machine-local settings
#
# Untracked, so absolute paths and host-specific tools stay out of this repo.
# Sourced last to let it override anything above. Mirrors the "include it if it
# exists" shape of .gitconfig's ~/.work.gitconfig.
#
# Keep this an `if`, not `[ -f ... ] && source ...`. It is the last statement in
# the file, so a short-circuited && leaves .zshenv exiting 1 on every machine
# without the file, which makes plain `zsh` exit non-zero.
if [ -f "$HOME/.zshenv.local" ]; then
  source "$HOME/.zshenv.local"
fi
