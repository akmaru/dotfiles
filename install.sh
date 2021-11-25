#!/bin/bash -ex

DOT_DIR=$(dirname $(readlink -f $0))

source ${DOT_DIR}/util/detect_os.sh
OS=`detect_os`

if [ $OS == "Mac" ]; then
  source install_mac.sh
elif [ $OS == "Linux" ]; then
  source install_ubuntu.sh
fi

#
# zsh
#
ln -sf ${DOT_DIR}/.zshrc ~/.zshrc
# curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh \| zsh
ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh
chsh -s /bin/zsh

#
# tmux
#
ln -sf ${DOT_DIR}/.tmux.conf ~/.tmux.conf

#
# git
#
ln -sf ${DOT_DIR}/.gitconfig ~/.gitconfig

#
# vim
#
ln -sf ${DOT_DIR}/.vim ~/.vim
ln -sf ${DOT_DIR}/.vimrc ~/.vimrc

#
# nvim
#
mkdir -p $HOME/.config/nvim
ln -sf ${DOT_DIR}/.vimrc $HOME/.config/nvim/init.vim

#
# emacs
#
mkdir -p ~/.emacs.d
ln -sf ${DOT_DIR}/.emacs.d/init.el ~/.emacs.d/init.el

#
# ssh
#
mkdir -p ~/.ssh
ln -sf ${DOT_DIR}/.ssh/config ~/.ssh/config


## Languages
### anyenv


### Rust
# . install_rust.sh

chsh
