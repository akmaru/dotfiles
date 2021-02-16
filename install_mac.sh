#!/bin/sh -ex

# In advance, run the following commands to install homebrew and git.
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew install git

ln -sf ~/dotfiles/.gitconfig_mac ~/.gitconfig_os

packages=("
  cmake \
  emacs \
  gdb \
  ghq \
  git-lfs \
  graphviz \
  llvm \
  make \
  neovim \
  ninja \
  rustup \
  tmux \
  unison \
")

cask_packages=("
  alfred
  bettersnaptool
  bettertouchtool
  docker
  google-japanese-ime
  google-chrome
  google-drive-file-stream
  karabiner-elements
  iterm2
  slack
  tunnelblock
  visual-studio-code
  xquartz
")

# Update
brew update

# Install brew-cask
brew cask

# Install packages
brew install $packages

# Install cask packages
brew cask install $cask_packages
