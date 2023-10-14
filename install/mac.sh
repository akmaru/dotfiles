#!/bin/sh
set -euox pipefail

# In advance, run the following commands to install homebrew and git.
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew install git

ln -sf $HOME/dotfiles/.gitconfig_mac $HOME/.gitconfig_os
# ln -sf $HOME/dotfiles/Brewfile $HONE/Brewfile

# Install packages
brew update && brew upgrade
brew bundle

# Set the destination path of screenshots
screenshot_location=$HOME/Pictures/Screenshots
mkdir -p $screenshot_location
defaults write com.apple.screencapture location $screenshot_location

# Modify key repeat frequencies
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)
