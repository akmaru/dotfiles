#!/bin/sh -ex

SCRIPT_DIR=$(cd $(dirname $0) && pwd)

source ../util/detect_os.sh
OS=`detect_os`

if [ $OS == "Mac" ]; then
  VSCODE_SETTING_DIR=~/Library/Application\ Support/Code/User
elif [ $OS == "Linux"]; then
  VSCODE_SETTING_DIR=~/.config/Code/User
else
  echo "OS: ${OS} is unknown."
  exit 1
fi

rm "${VSCODE_SETTING_DIR}/settings.json"
ln -s "${SCRIPT_DIR}/settings.json" "${VSCODE_SETTING_DIR}/settings.json"

rm "${VSCODE_SETTING_DIR}/keybindings.json"
ln -s "${SCRIPT_DIR}/keybindings.json" "${VSCODE_SETTING_DIR}/keybindings.json"

# install extention
cat extensions | while read line
do
 code --install-extension $line
done

code --list-extensions > extensions
