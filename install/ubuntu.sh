#!/bin/bash
set -euox pipefail

# If using pyenv, we have to install the packages by following:
# https://github.com/pyenv/pyenv/wiki#suggested-build-environment

packages=("
  apt-file \
  build-essential \
  cmake \
  emacs \
  gdb \
  git-lfs \
  graphviz \
  libbz2-dev \
  libffi-dev \
  libglib2.0-dev \
  liblzma-dev \
  libncursesw5-dev \
  libreadline-dev \
  libsqlite3-dev
  libssl-dev \
  libxml2-dev \
  libxmlsec1-dev \
  ninja-build \
  python3-neovim \
  tk-dev \
  xz-utils \
  zlib1g-dev \
") 
 
export DEBIAN_FRONTEND=noninteractive
sudo apt-get update \
  && sudo -E apt-get install -y --no-install-recommends $packages \
  && sudo apt-get clean && sudo rm -rf /var/lib/apt/lists/*
  