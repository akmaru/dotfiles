#!/bin/bash

function detect_os() {
  if [ "$(uname)" == 'Darwin' ]; then
    echo 'Mac'
  elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
    echo 'Linux'
  elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then                                                                                           
    echo 'Cygwin'
  else
    echo "Your platform ($(uname -a)) is not supported."
    exit 1
  fi

  return 0
}
