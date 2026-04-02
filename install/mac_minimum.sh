#!/bin/sh
set -euox pipefail

export DOT_PATH=$(dirname "$(readlink -f "$0")")

# In advance, run the following commands to install homebrew and git.
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew install git

ln -sf ${DOT_PATH}/.gitconfig_mac $HOME/.gitconfig_os
ln -sf ${DOT_PATH}/Brewfile_minimum $HOME/Brewfile_minimum

# Install packages
brew update && brew upgrade
brew bundle --file=$HOME/Brewfile_minimum

ln -sf ${DOT_PATH}/bin/claude-notify.sh $HOME/.local/bin/claude-notify.sh
ln -sf ${DOT_PATH}/bin/notify-server.sh $HOME/.local/bin/notify-server.sh
ln -sf ${DOT_PATH}/bin/iterm-jump.sh $HOME/.local/bin/iterm-jump.sh
