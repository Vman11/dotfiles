 #!/usr/bin/env bash
#__doc__='
#Explicitly setup symlinks
#'
sudo apt update && sudo apt upgrade
sudo apt install terminator

git config --global user.name "Vincenzo DiMatteo"
git config --global user.email "47278634+Vman11@users.noreply.github.com"

ln -sf "$(realpath .bashrc)" "$HOME"/.bashrc
ln -sf "$(realpath .terminator)" "$HOME"/.config/terminator/config
#ls -al "$HOME"

source "$HOME"/.bashrc

curl https://pyenv.run | bash


echo "
Next Steps:

source ./lib/pyenv_tools.sh
UPGRADE=1 install_pyenv
source ~/.bashrc
pyenv install --list

pyenv_create_virtualenv 3.11.2 off
source ~/.bashrc
"
