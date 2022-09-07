#!/usr/bin/env bash

git commit -am "$*"
git push || {
    git push --set-upstream origin "$(git rev-parse --abbrev-ref HEAD)"
    git push
}
