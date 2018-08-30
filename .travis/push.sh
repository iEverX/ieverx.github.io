#!/bin/sh

setup_git() {
    git config --global user.email "travis@travis-ci.org"
    git config --global user.name "Travis CI"
}

commit_files() {
    git init
    git add .
    git commit -m"Travis build: $TRAVIS_BUILD_NUMBER"
}

push() {
    git remote add origin-pages https://${GH_TOKEN}@github.com/iEverX/ieverx.github.io.git
    git push -f -u origin-pages master
}

cp CNAME public/
cd public
setup_git
commit_files
push