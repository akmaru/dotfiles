#!/bin/bash
set -euox pipefail

# In advance, run the following commands to install git.
# sudo apt install git

ln -sf ~/dotfiles/.gitconfig_linux ~/.gitconfig_os

packages=("
  ca-certificates \
  curl \
  make \
  neovim \
  tmux \
  zsh \
")

. /etc/os-release

case $VERSION_CODENAME in
  bionic)
    packages=("
      ${packages[@]} \
      libgnome-keyring-dev \
    ") 
    ;;
  focal | jammy)
    packages=("
      ${packages[@]} \
      fd-find \
      libsecret-1-0 \
      libsecret-1-dev \
      ripgrep \
    ")
    ;;
  *)
    echo "$0 not support to install in ${VERSION_CODENAME}"
    exit 1
    ;;
esac

export DEBIAN_FRONTEND=noninteractive
sudo apt-get update \
  && sudo -E apt-get install -y --no-install-recommends $packages \
  && sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*
 
# Build gnome-keyring (for git credential)
case $VERSION_CODENAME in
  bionic)
    sudo make -C /usr/share/doc/git/contrib/credential/gnome-keyring || true
    ;;
  focal | jammy)
    sudo make -C /usr/share/doc/git/contrib/credential/libsecret || true
    ;;
esac
