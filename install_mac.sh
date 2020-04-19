#!/bin/sh -ex

packages=("
  cmake \
  emacs \
  gdb \
  ghq \
  git-lfs \
  graphviz \
  make \
  neovim \
  ninja \
  rustup \
  tmux \
  unison \
")

cask_packages=("
  docker
  google-chrome
  handbrake
")

# Update & upgrade
brew update
brew upgrade

# Install brew-cask
brew cask

# Install brew packages
brew install $packages

# Install brew-cask packages
brew cask install $cask_packages
