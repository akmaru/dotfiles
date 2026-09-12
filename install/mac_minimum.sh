#!/bin/sh
set -euox pipefail

# Set DOT_PATH if not already set (exported by install_minimum.sh when sourced)
DOT_PATH="${DOT_PATH:-$(cd "$(dirname "$0")/.."; pwd)}"

# In advance, run the following commands to install homebrew and git.
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew install git

ln -sf ${DOT_PATH}/Brewfile_minimum $HOME/Brewfile_minimum

# Install packages
brew update && brew upgrade
brew bundle --file=$HOME/Brewfile_minimum
