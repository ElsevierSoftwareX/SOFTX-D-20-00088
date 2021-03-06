#!/bin/bash
set -x #echo on
git checkout production
read -p 'New branch name (i.e. release-v2.0.0): ' new_branch_name
git merge $new_branch_name --no-ff
git push origin production
git branch -D $new_branch_name
git push --delete origin $new_branch_name
read -p 'New tag name (i.e. v2.0.0): ' new_tag_name
git tag $new_tag_name
git push origin $new_tag_name