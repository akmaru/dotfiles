#!/bin/sh -ex

# In advance, run the following commands to install git.
# sudo apt install git

ln -sf ~/dotfiles/.gitconfig_ubuntu ~/.gitconfig_os

packages=("
  build-essential \
  cmake \
  curl \
  emacs \
  gdb \
  git-lfs \
  graphviz \
  libgnome-keyring-dev \
  neovim \
  ninja-build \
  python3-neovim \
  tmux \
")

# Update
sudo apt update

# Install packages
sudo apt install $packages

# Build gnome-keyring (for git credential)
sudo make -C /usr/share/doc/git/contrib/credential/gnome-keyring

