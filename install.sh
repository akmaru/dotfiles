#!/bin/sh -x

# zsh
ln -sf ~/dotfiles/.zshrc ~/.zshrc
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh \| zsh

# tmux
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

# git
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

# rtags
git clone --recursive https://github.com/Andersbakken/rtags.git
# cd rtags
# mkdir build
# cd build
# cmake ..
# make
# make install
# cd ../../

# nvim
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/nvim/init.vim ~/.config/nvim/init.vim

# emacs
mkdir -p ~/.emacs.d
ln -sf ~/dotfiles/.emacs.d/init.el ~/.emacs.d/init.el

# ssh
mkdir -p ~/.ssh
ln -sf ~/dotfiles/.ssh/config ~/.ssh/config
