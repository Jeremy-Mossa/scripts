#!/bin/bash

Dir="/home/fedora41/dotfiles"

df=(
  ".bashrc"
  ".bash_profile"
  ".cron"
  ".dependency"
  ".dillo/"
  ".fluxbox/"
  ".vimrc"
  ".xinitrc"
  ".Xresources"
)

# Alphabetical sorting of the .dependency file before sync
cat ~/Documents/to_install.txt | sort > ~/Documents/sorted
cat ~/Documents/sorted > ~/Documents/to_install.txt
cp ~/Documents/to_install.txt ~/.dependency
rm ~/Documents/sorted

cd ~

for f in "${df[@]}"; do
  if [ -e "$f" ]; then
    cp -r "$f" "$Dir"
  else
    echo "File not found: $file"
  fi
done

cd "$Dir" || exit
git add .
git commit -m "Scheduled backup of dotfiles" || echo "no changes" 
git push || echo "git push failure"
