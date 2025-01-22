#!/bin/bash
# Find all directories containing a .git/ folder
git_dirs=$(find $HOME -type d -name ".git" -prune -exec dirname {} \;) 

for dir in $git_dirs; do
	cd "$dir" || continue
  # Pull first in case editing was done on github
  git pull ssh main
	git add .
	git commit -m "Automated commit by using crontab" || echo "No \
		changes to commit in $dir."
	git push ssh main || echo "Failed to push changes in $dir." 
done
