#!/bin/sh -ex

packages=("
  cmake \
  emacs \
  gdb \
  graphviz \
  make \
  neovim \
  ninja \
  rustup \
  tmux \
")

brew update
brew upgrade
brew install $packages
