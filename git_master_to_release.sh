#!/bin/bash
set -x #echo on
git checkout production
read -p 'New branch name (i.e. release-v2.0.0): ' new_branch_name
git checkout -b $new_branch_name
git merge --no-commit --no-ff master
git mergetool
git clean -fd
git commit -m "Merge branch 'master' into $new_branch_name."
git push origin $new_branch_name