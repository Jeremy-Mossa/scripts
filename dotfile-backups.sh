#!/bin/bash

Dir="/home/fedora41/dotfiles"

df=(
  ".bashrc"
  ".bash_profile"
  ".cron"
  ".dillo/"
  ".fluxbox/"
  ".vimrc"
  ".xinitrc"
  ".Xresources"
)

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
