# In advance, install chocolatey and git by chocolatey.
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
# choco install git

packages=("
  cmake \
  emacs \
  ghq \
  git-lfs \
  graphviz \
  llvm \
  make \
  neovim \
  ninja \
  rustup \
  tmux \
  unison \
")

choco install $packages
