#!/bin/sh

# zsh
ln -sf ~/dotfiles/.zshrc ~/.zshrc
curl -sL --proto-redir -all,https https://zplug.sh/installer | zsh

# tmux
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

# git
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

# rtags
git clone --recursive https://github.com/Andersbakken/rtags.git
cd rtags
mkdir build
cd build
cmake ..
make
make install
cd ../../

# emacs
mkdir -p ~/.emacs.d
ln -sf ~/dotfiles/.emacs.d/init.el ~/.emacs.d/init.el

# ssh
mkdir -p ~/.ssh
ln -sf ~/dotfiles/.ssh/config ~/.ssh/config
