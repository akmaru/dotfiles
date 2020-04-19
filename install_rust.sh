#!/bin/sh -ex

echo "### Setup: Rust ###"

rustup-init

EXIST_SOURCE=`grep -c "## Rust" ~/.zshenv`

if [ -z "$EXIST_SOURCE" ]; then
  echo "\n\
## Rust \n\
source $HOME/.cargo/env \n\
" >> ~/.zshenv
fi
