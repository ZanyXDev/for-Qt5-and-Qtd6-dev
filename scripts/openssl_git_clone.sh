#!/bin/bash
set -e
REPOSRC=$1
LOCALREPO=$2

git clone --depth 1 "$REPOSRC" "$LOCALREPO" 2> /dev/null || (git -C "$LOCALREPO" pull)
