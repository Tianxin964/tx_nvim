#!/bin/bash

# This script is install neovim

print_status() {
    echo
    echo  "## $1"
    echo
}

if test -t 1; then # if terminal
    ncolors=$(which tput > /dev/null && tput colors) # supports color
    if test -n "$ncolors" && test $ncolors -ge 8; then
        termcols=$(tput cols)
        bold="$(tput bold)"
        underline="$(tput smul)"
        standout="$(tput smso)"
        normal="$(tput sgr0)"
        black="$(tput setaf 0)"
        red="$(tput setaf 1)"
        green="$(tput setaf 2)"
        yellow="$(tput setaf 3)"
        blue="$(tput setaf 4)"
        magenta="$(tput setaf 5)"
        cyan="$(tput setaf 6)"
        white="$(tput setaf 7)"
    fi
fi


bail() {
    echo 'Error executing command, exiting'
    exit 1
}

exec_cmd_nobail() {
    echo "+ $1"
    bash -c "$1"
}

exec_cmd() {
    exec_cmd_nobail "$1" || bail
}

# Populating Cache
print_status ${bold}${red}"Populating apt-get cache..."${normal}


asktoinstallnode() { \
  echo "node not found"
  echo -n "Would you like to install node now (y/n)? "
  read answer
  [ "$answer" != "${answer#[Yy]}" ] && installnode && installcocextensions
}

installpopular() {
   echo -n ${bold}${green}"Would you like to update (y/n)? "${normal}
   read answer
   [ "$answer" != "${answer#[Yy]}" ] && exec_cmd 'apt-get update'

   echo -n ${bold}${green}"Would you like to install vim (y/n)?"${normal}
   read answer
   [ "$answer" != "${answer#[Yy]}" ] && exec_cmd 'apt-get install vim'
}

installneovim() {
    # Install nvim and other
    print_status ${bold}${red}"Install neovim"${normal}
    exec_cmd 'apt-get install software-properties-common'
    exec_cmd 'add-apt-repository ppa:neovim-ppa/stable'
    exec_cmd 'apt-get update && apt-get install neovim'
}

installubuntu() {
    print_status ${bold}${red}"Install python-dev"${normal}
    exec_cmd 'apt install -y python-dev python-pip python3-dev python3-pip python3-setuptools'
    
    print_status ${bold}${red}"Install curl git wget libssl-dev libffi-dev locale"${normal}
    exec_cmd 'apt-get install -y curl git wget libssl-dev libffi-dev locate > /dev/null'

    print_status ${bold}${red}"Install ranger"${normal}
    exec_cmd 'apt-get install ranger'
}

installextrapackages() { \
  [  -n "$(uname -a | grep Ubuntu)" ] && installubuntu
}

installnodejs() {
    print_status ${bold}${red}"Install nodejs>=14.15.0"${normal}
    exec_cmd 'curl -sL install-node.now.sh/lts | bash'
    exec_cmd 'apt-get install nodejs'
}

installripgrep() {
    print_status ${bold}${red}"Install ripgrep"${normal}
    exec_cmd 'curl https://sh.rustup.rs -sSf | bash'
    exec_cmd 'mkdir -p ~/software/ripgrep'
    exec_cmd 'git clone https://github.com/BurntSushi/ripgrep ~/software/ripgrep'
    exec_cmd 'cd ~/software/ripgrep'
    exec_cmd 'cargo build --release'
    exec_cmd 'cp ./target/release/rg /usr/local/bin/'
}

installnpm() {
    print_status ${bold}${red}"Install npm"${normal}
    exec_cmd 'apt-get install npm'
    print_status ${bold}${red}"Install npm-neovim"${normal}
    exec_cmd 'npm i -g neovim'
}

cloneconfig() { \
    print_status ${bold}${red}"Cloning Nvim Mach 2 configuration"${normal}
    exec_cmd 'mkdir -p ~/.config/nvim'
    exec_cmd 'git clone https://github.com/Tianxin964/tx_nvim.git ~/.config/nvim'
}


installpynvim() {
   print_status ${bold}${red}"Install pynvim"${normal}
   exec_cmd 'pip install pynvim --user'
   exec_cmd 'pip install neovim-remote'
}

installplugins() { \
    mv $HOME/.config/nvim/init.vim $HOME/.config/nvim/init.vim.tmp
    mv $HOME/.config/nvim/utils/init.vim $HOME/.config/nvim/init.vim
    echo "Installing plugins..."
    nvim --headless +PlugInstall +qall > /dev/null 2>&1
    mv $HOME/.config/nvim/init.vim $HOME/.config/nvim/utils/init.vim
    mv $HOME/.config/nvim/init.vim.tmp $HOME/.config/nvim/init.vim
}

installcocextensions() { \
    # Install extensions
    print_status ${bold}${red}"Install coc"${normal}
    mkdir -p ~/.config/coc/extensions
    cd ~/.config/coc/extensions
    [ ! -f package.json ] && echo '{"dependencies":{}}'> package.json
    # Change extension names to the extensions you need
    npm install coc-explorer coc-snippets coc-json coc-actions --global-style --ignore-scripts --no-bin-links --no-package-lock --only=prod
}
## ================================================================================ ##
#                                welcome install
## ================================================================================ ##

echo -n ${bold}${green}"Would you like to install neovim (y/n) ?"${normal}
read answer
[ "$answer" != "${answer#[Yy]}" ] && installneovim

echo -n ${bold}${green}"Would you like to install ertra packages (y/n) ?"${normal}
read answer
[ "$answer" != "${answer#[Yy]}" ] && installextrapackages


if [ -d `which nodejs` ];then
    installnodejs
fi
if [ -d `which rg` ];then
    installripgrep
fi
if [ -d `which npm` ];then
    installnpm
fi

echo -n ${bold}${green}"Would you like to install npm (y/n) ?"${normal}
read answer
[ "$answer" != "${answer#[Yy]}" ] && installnpm

# install pynvim
pip list | grep pynvim > /dev/null && print_status ${bold}${red}"pynvim installed, moving on..."${normal} || installpynvim

cloneconfig

# install plugins
which nvim > /dev/null && installplugins

installcocextensions

echo "done!"
