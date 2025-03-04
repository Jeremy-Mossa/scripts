#!/bin/bash

# Elevate privileges before install
sudo -v

rm -r ~/Desktop ~/Videos ~/Music \
  ~/Templates ~/Pictures 2>/dev/null

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

for f in $(find / -iname *gnome* 2>/dev/null); do 
  rm -r $f
done

gotslim=$(which slim)
gdmstatus=$(systemctl status gdm | grep disabled | cut -d";" -f2)
if [ $gotslim = "/bin/slim" ] && [ $gdmstatus != "disabled" ]; then 
  sudo systemctl disable gdm 2>/dev/null
  sudo systemctl enable slim 2>/dev/null
else
  echo "gdm status: $gdmstatus"
fi

# main.zip is ~22MB
if [ ! -d ~/Storage ]; then
  wget -O storage.zip \
  https://github.com/Jeremy-Mossa/Storage/archive/main.zip
  unzip storage.zip
  rm storage.zip
  mv Storage-main ~/downloads/Storage
fi

echo '@reboot root echo 85 > /sys/class/power_supply/BAT0/charge_control_end_threshold' >> /etc/crontab
