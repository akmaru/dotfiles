#!/bin/sh -ex

# In advance, run the following commands to install git.
# sudo apt install git

ln -sf ~/dotfiles/.gitconfig_ubuntu ~/.gitconfig_os

# For Ubuntu-18.04
packages=("
  apt-file
  build-essential \
  cmake \
  curl \
  emacs \
  gdb \
  git-lfs \
  graphviz \
  libglib2.0-dev \
  libgnome-keyring-dev \
  neovim \
  ninja-build \
  python3-neovim \
  tmux \
")


# For Ubuntu-20.04
#packages=("
#  apt-file
#  build-essential \
#  cmake \
#  curl \
#  emacs \
#  gdb \
#  git-lfs \
#  graphviz \
#  libglib2.0-dev \
#  libsecret-1-0 \
#  libsecret-1-dev \
#  neovim \
#  ninja-build \
#  python3-neovim \
#  tmux \
#")

# Update
sudo apt update -y

# Install packages
sudo apt install -y $packages

# Build gnome-keyring (for git credential)
sudo make -C /usr/share/doc/git/contrib/credential/gnome-keyring
# sudo make -C /usr/share/doc/git/contrib/credential/libsecret
