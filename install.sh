#!/bin/sh

# zsh
ln -sf ~/dotfiles/.zshrc ~/.zshrc

# tmux
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf

# git
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig

# emacs
mkdir ~/.emacs.d
ln -sf ~/dotfiles/.emacs.d/init.el ~/.emacs.d/init.el

# ssh
mkdir ~/.ssh
ln -sf ~/dotfiles/.ssh/config ~/.ssh/config
