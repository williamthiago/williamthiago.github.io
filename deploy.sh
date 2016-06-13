#!/usr/bin/env bash
set -e # halt script on error

# config
git config --global user.email "williamthiago@gmail.com"
git config --global user.name "William Thiago"
git config --global push.default matching
git config --global core.autocrlf false
git config --global credential.helper store
echo "https://${GH_TOKEN}:@github.com" > ~/.git-credentials

# deploy
if [[ `git status --porcelain` ]]; then
    git stash
    git checkout develop
    git stash apply
    git add .
    git commit -m 'Updated from travis [ci skip]'
    git push origin develop
fi

cd ${HTML_FOLDER}

git init
git add --all
git commit -m "Deploy to GitHub Pages"
git remote add origin ${GH_REMOTE}
git push --force --quiet origin master