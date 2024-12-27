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
# There's probably a more compact way to do this
cat ~/Documents/to_install.txt | sort > ~/Documents/sorted
cat ~/Documents/sorted > ~/Documents/to_install.txt
cp ~/Documents/to_install.txt ~/.dependency
rm ~/Documents/sorted

cd ~

for f in "${df[@]}"; do
  if [ -e "$f" ]; then
    cp -r "$f" "$Dir"
  else
    echo "File/Directory not found: $f"
  fi
done

cd "$Dir" || exit
git pull # Pull first in case edited in GitHub
git add .
git commit -m "Scheduled backup of dotfiles" || echo "no changes" 
git push || echo "git push failure"
