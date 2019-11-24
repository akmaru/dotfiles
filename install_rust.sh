#!/bin/sh -ex

echo "### Setup: Rust ###"

rustup-init

if [ -z `grep -c "## Rust" ~/.zshenv` ]; then
  echo "\n\
## Rust \n\
export CARGO_HOME=\"$HOME/.cargo\" \n\
export PATH=\"$CARGO_HOME/bin:$PATH\" \n\
" >> ~/.zshenv
fi
