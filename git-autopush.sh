#!/bin/sh
# git-autopush.sh – POSIX version
# Automatically pull → commit → push only your personal repositories

# —————————————————————————————————————————————————————————————
# add new REPOS when created
# from grok 4.1
# updated 5 DEC 2025
# —————————————————————————————————————————————————————————————

REPOS="$HOME/scripts
$HOME/dotfiles
$HOME/Storage"
# ← add more repos here later if needed

for repo in $REPOS; do
    [ ! -d "$repo/.git" ] && {
        printf 'Skipping %s (not a git repository)\n' "$repo"
        continue
    }

    printf '============================================\n'
    printf 'Processing → %s\n' "$repo"
    printf '============================================\n'

    cd "$repo" || continue

    # ——— Stash any local changes before pulling ———
    if git status --porcelain | grep -q .; then
        printf 'Local changes detected → stashing them temporarily\n'
        git stash push -m "autopush-stash-$(date '+%Y%m%d-%H%M%S')" >/dev/null
        STASHED=1
    else
        STASHED=0
    fi

    # ——— Pull with rebase ———
    if git pull --rebase ssh://git@github.com/Jeremy-Mossa/$(basename "$repo").git main; then
        printf 'Pull succeeded\n'
        PULL_OK=1
    else
        printf 'Pull failed — will try to continue anyway\n'
        git rebase --abort 2>/dev/null   # clean up possible half-done rebase
        PULL_OK=0
    fi

    # ——— Re-apply stash if we had one ———
    if [ "$STASHED" -eq 1 ]; then
        if git stash pop --index 2>/dev/null; then
            printf 'Stash re-applied successfully\n'
        else
            printf 'Stash conflict — keeping stash for manual resolution\n'
        fi
    fi

    # ——— Stage everything that is actually modified now ———
    git add -A

    # ——— Commit only if there are staged changes ———
    if git diff --cached --quiet 2>/dev/null; then
        printf 'No changes to commit\n'
    else
        git commit -m "Auto-commit — $(date '+%Y-%m-%d %H:%M:%S')" \
            && printf 'Committed changes\n'
    fi

    # ——— Push ———
    if git show-ref --quiet --heads main; then
        if git push ssh://git@github.com/Jeremy-Mossa/$(basename "$repo").git main; then
            printf 'Pushed successfully\n'
        else
            printf 'Push failed\n'
        fi
    else
        printf 'No local "main" branch — nothing to push\n'
    fi

    printf '\n'
done

printf 'All repositories processed.\n'
