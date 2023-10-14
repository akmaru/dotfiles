#!/bin/bash
set -euox pipefail

FZF_VERSION='0.42.0'

case $OSTYPE in
  linux*)
    FZF_CLONE_DST_PATH=${XDG_DATA_HOME}/fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git -b ${FZF_VERSION} ${FZF_CLONE_DST_PATH}
    ${FZF_CLONE_DST_PATH}/install --xdg --key-bindings --completion --update-rc
    ln -sf ${FZF_CLONE_DST_PATH}/bin/fzf ${XDG_BIN_HOME}/fzf
    ;;
  darwin*)
    # fzf will be installed by brew
    type "fzf"
esac
