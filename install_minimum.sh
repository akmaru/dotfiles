#!/bin/bash
set -euxo pipefail

export DOT_PATH=$(dirname "$(readlink -f "$0")")

case $OSTYPE in
  linux*)
    ${DOT_PATH}/install/ubuntu_minimum.sh
    ;;
  darwin*)
    ${DOT_PATH}/install/mac_minimum.sh
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
source "${DOT_PATH}"/install/mise.sh

#
# zsh
#
ln -sf ${DOT_PATH}/.zshenv ~/.zshenv
ln -sf ${DOT_PATH}/.zshrc ~/.zshrc
ln -sf ${DOT_PATH}/.p10k.zsh ~/.p10k.zsh
# 実ディレクトリ/ファイルが先に存在すると symlink が入れ子になるため、その場合は中断
if [ -e "${XDG_CONFIG_HOME}/zsh" ] && [ ! -L "${XDG_CONFIG_HOME}/zsh" ]; then
  echo "Error: ${XDG_CONFIG_HOME}/zsh already exists. Remove it and re-run: rm -rf ${XDG_CONFIG_HOME}/zsh" >&2
  exit 1
fi
ln -sfn ${DOT_PATH}/zsh ${XDG_CONFIG_HOME}/zsh
case $OSTYPE in
  linux*)
    sudo chsh "$(whoami)" -s "$(which zsh)"
    ;;
esac

#
# tmux
#
ln -sf ${DOT_PATH}/.tmux.conf ~/.tmux.conf

#
# git
#
ln -sf ${DOT_PATH}/.gitconfig ~/.gitconfig
ln -sf ${DOT_PATH}/.gitignore_global ~/.gitignore_global

#
# vim
#
# -n is required for the directory link: without it a re-run dereferences the
# existing ~/.vim symlink and creates .vim/.vim inside the repo instead of
# replacing the link. That artifact used to get committed, rewritten with
# whichever machine ran install last.
ln -sfn ${DOT_PATH}/.vim ~/.vim
ln -sf ${DOT_PATH}/.vimrc ~/.vimrc

#
# nvim (LazyVim)
#
# ディレクトリごとリンクすることで、LazyVim が書き出す lazyvim.json / lazy-lock.json が
# リポジトリ側に残り、構成をそのまま追跡できる
# 実ディレクトリ/ファイルが先に存在すると symlink が入れ子になるため、その場合は中断
if [ -e "${XDG_CONFIG_HOME}/nvim" ] && [ ! -L "${XDG_CONFIG_HOME}/nvim" ]; then
  echo "Error: ${XDG_CONFIG_HOME}/nvim already exists. Back it up and re-run: mv ${XDG_CONFIG_HOME}/nvim{,.bak}" >&2
  exit 1
fi
ln -sfn ${DOT_PATH}/nvim ${XDG_CONFIG_HOME}/nvim

# herdr はプラグイン pane やカスタムコマンドを mise の shim を含まない PATH で起動するため、
# XDG_BIN_HOME 経由でも mise 管理の nvim に届くようにする
ln -sfn ${XDG_DATA_HOME}/mise/shims/nvim ${XDG_BIN_HOME}/nvim

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
mkdir -p ~/.ssh/config.d

#
# aws
#
mkdir -p ~/.aws/conf.d
ln -sf ${DOT_PATH}/.aws/conf.d/personal.conf ~/.aws/conf.d/personal.conf
# set -e 下で末尾に置くと、リンクでない場合に && の終了コード 1 がそのまま
# スクリプトの終了コードになるため if で書く
if [ -L ~/.aws/config ]; then
  rm -f ~/.aws/config
fi
