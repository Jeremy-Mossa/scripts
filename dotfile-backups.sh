#!/bin/bash

if [ ! -d ~/dotfiles ]; then
  mkdir ~/dotfiles
fi

Dir="/home/jbm/dotfiles"

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
# Research a more compact way to do this
sort ~/.dependency > ~/tmp_dep
cat ~/tmp_dep > ~/.dependency
rm ~/tmp_dep

cd ~

for f in "${df[@]}"; do
  if [ -e "$f" ]; then
    cp -r "$f" "$Dir"
  else
    echo "File/Directory not found: $f"
  fi
done

cd "$Dir" || exit
git add .
git commit -m "Scheduled backup of dotfiles" || echo "no changes" 
git push ssh main || echo "git push failure"
