#!/bin/bash
set -euxo pipefail

export DOT_PATH=$(dirname "$(readlink -f "$0")")

case $OSTYPE in
  linux*)
    ${DOT_PATH}/install/ubuntu_minimum.sh
    ;;
  darwin*)
    # TODO: separase install/mac.sh
    ${DOT_PATH}/install/mac.sh
    ;;
  *)
    echo "$0 not support to install in ${OSTYPE}"
    exit 1
    ;;
esac

#
# Create XDG Base Directory 
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
#

export XDG_BIN_HOME=$HOME/.local/bin
export XDG_CACHE_HOME=$HOME/.cache
export XDG_CONFIG_HOME=$HOME/.config
export XDG_DATA_HOME=$HOME/.local/share
export XDG_LIB_HOME=$HOME/.local/lib
export XDG_STATE_HOME=$HOME/.local/state

mkdir -p ${XDG_BIN_HOME}
mkdir -p ${XDG_CACHE_HOME}
mkdir -p ${XDG_CONFIG_HOME}
mkdir -p ${XDG_DATA_HOME}
mkdir -p ${XDG_LIB_HOME}
mkdir -p ${XDG_STATE_HOME}

#
# Sheldon
#
"${DOT_PATH}"/install/sheldon.sh

#
# mise
#
"${DOT_PATH}"/install/mise.sh

#
# zsh
#
ln -sf ${DOT_PATH}/.zshrc ~/.zshrc
ln -sf ${DOT_PATH}/.p10k.zsh ~/.p10k.zsh
sudo chsh "$(whoami)" -s "$(which zsh)"

#
# tmux
#
ln -sf ${DOT_PATH}/.tmux.conf ~/.tmux.conf

#
# git
#
ln -sf ${DOT_PATH}/.gitconfig ~/.gitconfig

#
# vim
#
ln -sf ${DOT_PATH}/.vim ~/.vim
ln -sf ${DOT_PATH}/.vimrc ~/.vimrc

#
# nvim
#
mkdir -p $HOME/.config/nvim
ln -sf ${DOT_PATH}/.vimrc $HOME/.config/nvim/init.vim

#
# emacs
#
mkdir -p ~/.emacs.d
ln -sf ${DOT_PATH}/.emacs.d/init.el ~/.emacs.d/init.el

#
# ssh
#
mkdir -p ~/.ssh
ln -sf ${DOT_PATH}/.ssh/config ~/.ssh/config

#
# Claude Code
#
"${DOT_PATH}"/install/claude_code.sh

