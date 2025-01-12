#!/bin/bash
# Find all directories containing a .git/ folder
git_dirs=$(find $HOME -type d -name ".git" -prune -exec dirname {} \;) 

for dir in $git_dirs; do
	cd "$dir" || continue
	git add .
	git commit -m "Automated commit by using crontab" || echo "No \
		changes to commit in $dir."
	git push origin main || echo "Failed to push changes in $dir." 
    # Pull first in case editing was done on github
    git pull origin main
done
