#!/bin/sh
set -euox pipefail

# In advance, run the following commands to install homebrew and git.
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew install git

ln -sf $HOME/dotfiles/.gitconfig_mac $HOME/.gitconfig_os
ln -sf $HOME/dotfiles/Brewfile_minimum $HOME/Brewfile_minimum

# Install packages
brew update && brew upgrade
brew bundle --file=$HOME/Brewfile_minimum
