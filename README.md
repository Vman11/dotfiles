# Installation

The following bash instructions install git, clone this repo, and initializes
it, which will symlink the configurations to the appropriate places in your
home directory.

```bash
#sudo apt install git -y
REPO_URI=https://github.com/Vman11/dotfiles.git
git clone "$REPO_URI" "$HOME/dotfiles"
cd "$HOME"/dotfiles
./install.sh
```