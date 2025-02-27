#!/bin/bash

# Elevate privileges before install
sudo -v

rm -r ~/Desktop ~/Videos ~/Music \
  ~/Templates ~/Pictures 2>/dev/null

if [ ! -d ~/Storage ]; then
  mkdir ~/Storage
  wget https://github.com/Jeremy-Mossa/Storage/archive/main.zip
fi

if [ ! -d ~/books ]; then
  mkdir ~/books
fi

if [ ! -d ~/C ]; then
  mkdir ~/C
fi

if [ ! -d ~/scripts ]; then
  git clone https://github.com/Jeremy-Mossa/scripts
fi

if [ ! -d ~/dotfiles ]; then
  git clone https://github.com/Jeremy-Mossa/dotfiles
fi

if [ ! -n ~/downloads ]; then
  ln -s ~/Downloads downloads
fi

if [ ! -n ~/perl ]; then
  mkdir ~/perl
fi

for line in $(cat ~/.dependency); do
  yes | sudo dnf install $line
done

gotslim=$(which slim)
gdmstatus=$(systemctl status gdm | grep disabled | cut -d";" -f2)
if [ $gotslim = "/bin/slim" ] && [ $gdmstatus != "disabled" ]; then 
  sudo systemctl disable gdm 2>/dev/null
  sudo systemctl enable slim 2>/dev/null
else
  echo "gdm status: $gdmstatus"
fi

