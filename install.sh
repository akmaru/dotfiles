#!/bin/sh -ex

source util/detect_os.sh
OS=`detect_os`

if [ $OS == "Mac" ]; then
  source install_mac.sh
fi

## zsh
ln -sf ~/dotfiles/.zshrc ~/.zshrc
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh \| zsh
ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh

## tmux
ln -sf ~/dotfiles/.tmux.conf ~/.tmux.conf


## git
ln -sf ~/dotfiles/.gitconfig ~/.gitconfig


## nvim
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/nvim/init.vim ~/.config/nvim/init.vim


## emacs
mkdir -p ~/.emacs.d
ln -sf ~/dotfiles/.emacs.d/init.el ~/.emacs.d/init.el

### rtags
# git clone --recursive https://github.com/Andersbakken/rtags.git
# cd rtags
# mkdir build
# cd build
# cmake ..
# make
# make install
# cd ../../


## VSCode
cd .vscode && . install_vscode.sh && cd ../


## ssh
mkdir -p ~/.ssh
ln -sf ~/dotfiles/.ssh/config ~/.ssh/config


## Languages
### Rust
. install_rust.sh
