$packages=("
  cmake
  emacs
  ghq
  git-lfs
  ninja
  python3
  rust
  tmux")

choco update
choco upgrade
choco install -y $packages
