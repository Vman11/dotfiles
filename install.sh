 #!/usr/bin/env bash
#__doc__='
#Explicitly setup symlinks
#'
sudo apt update && sudo apt upgrade
sudo apt install terminator
sudo apt install curl
sudo apt install sl

git config --global user.name "Vincenzo DiMatteo"
git config --global user.email "47278634+Vman11@users.noreply.github.com"
#ssh-keygen -t ed25519 -C "47278634+Vman11@users.noreply.github.com"

ln -sf "$(realpath .bashrc)" "$HOME"/.bashrc
ln -sf "$(realpath .terminator)" "$HOME"/.config/terminator/config
#ls -al "$HOME"

source "$HOME"/.bashrc

#curl https://pyenv.run | bash
#curl -f https://zed.dev/install.sh | sh

if ls $HOME/Downloads/code*.deb 1> /dev/null 2>&1; then
    sudo apt install $HOME/Downloads/code*.deb
else
    echo "VSCODE not found in Downloads... ignoring..."
fi

echo "
Next Steps:

source ./lib/pyenv_tools.sh
UPGRADE=1 install_pyenv
source ~/.bashrc
pyenv install --list

pyenv_create_virtualenv 3.11.2 off
source ~/.bashrc
"
