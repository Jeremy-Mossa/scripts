#!/bin/bash
# Find all directories containing a .git/ folder
git_dirs=$(find $HOME -type d -name ".git" -prune -exec dirname {} \;) 

for dir in $git_dirs; do
	cd "$dir" || continue
	git add .
	git commit -m "Automated commit from systemd service" || echo "No \
		changes to commit in $dir."
	git push || echo "Failed to push changes in $dir." 
done
