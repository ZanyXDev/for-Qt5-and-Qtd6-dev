#!/bin/bash
set -e
REPOSRC=$1
LOCALREPO=$2

#https://stackoverflow.com/questions/71849415/i-cannot-add-the-parent-directory-to-safe-directory-in-git
git config --global --add safe.directory '*'
git clone --depth 1 "$REPOSRC" "$LOCALREPO" 2> /dev/null || (git -C "$LOCALREPO" pull)
