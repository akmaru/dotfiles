#!/bin/bash -ex

DOT_DIR=$(dirname $(readlink -f $0))

#
# apt
#
apt_packages=("
  git \
  git-lfs \
  zsh \
  libgnome-keyring-dev \
  neovim \
  tmux \
")

sudo apt update && sudo apt install -y $packages

#
# zsh
#
ln -sf ${DOT_DIR}/.zshrc ~/.zshrc
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh \| zsh
ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh
chsh -s /bin/zsh

#
# tmux
#
ln -sf ${DOR_DIR}/.tmux.conf ~/.tmux.conf

#
# git
#
ln -sf ${DOR_DIR}/.gitconfig ~/.gitconfig

#
# vim
#
ln -sf ${DOR_DIR}/.vim ~/.vim
ln -sf ${DOT_DIR}/.vimrc ~/.vimrc
git clone https://github.com/tomasr/molokai

#
# nvim
#
mkdir -p $HOME/.config/nvim
ln -sf ${DOT_DIR}/nvim/init.vim $HOME/.config/nvim/init.vim

#
# emacs
#
mkdir -p ~/.emacs.d
ln -sf ${DOT_DIR}/.emacs.d/init.el ~/.emacs.d/init.el

#
# VSCode
#
# cd .vscode && . install_vscode.sh && cd ../
