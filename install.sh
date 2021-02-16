#!/bin/bash -ex

DOT_DIR=$(dirname $(readlink -f $0))

#source util/detect_os.sh
#OS=`detect_os`

if [ $OS == "Mac" ]; then
  source install_mac.sh
elif [ $OS == "Linux" ]; then
  source install_ubuntu.sh
fi

#
# zsh
#
ln -sf ${DOT_DIR}/.zshrc ~/.zshrc
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh \| zsh
ln -sf ~/dotfiles/.p10k.zsh ~/.p10k.zsh

#
# tmux
#
ln -sf ${DOR_DIR}/.tmux.conf ~/.tmux.conf

#
# git
#
ln -sf ${DOR_DIR}/.gitconfig ~/.gitconfig

#
# vim
#
ln -sf ${DOT_DIR}/.vimrc ~/.vimrc
git clone https://github.com/tomasr/molokai
mkdir -p ~/.vim/colors
cp ./molokai/colors/monokai.vim ~/.vim/colors

#
# nvim
#
mkdir -p $HOME/.config/nvim
ln -sf ${DOT_DIR}/nvim/init.vim $HOME/.config/nvim/init.vim

#
# emacs
#
mkdir -p ~/.emacs.d
ln -sf ${DOT_DIR}/.emacs.d/init.el ~/.emacs.d/init.el

#
# VSCode
#
cd .vscode && . install_vscode.sh && cd ../

#
# ssh
#
mkdir -p ~/.ssh
ln -sf ${DOT_DIR}/.ssh/config ~/.ssh/config


## Languages
### anyenv


### Rust
. install_rust.sh
