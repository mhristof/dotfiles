#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
#set -euo pipefail
#IFS=$'\n\t'


echo 'shred -u .bash_history'
echo 'shred -u .zsh_history'
echo 'docker ps -aq | xargs docker rm -f'
echo 'docker images  -q | xargs docker rmi -f'
echo osascript -e 'quit app "Docker"'
echo 'rm ~/Library/Application\ Support/Alfred -rf'
echo 'rm ~/Library/Preferences/com.runningwithcrayons.Alfred-Preferences.plist'
echo 'rm ~/Library/Preferences/com.alfredapp.Alfred.plist'
echo 'rm ~/Library/Caches/com.runningwithcrayons.Alfred'
echo 'find ~/Library/Containers/com.apple.Notes/Data/Library/Notes -type f -print0 | xargs -0 shred -u'
echo 'find ~/Library/Application\ Support/Google/Chrome/Default -type f -print0 | xargs -0 shred -u'
echo 'find ~/.ssh -type f -print0 | xargs -0 shred -u'
echo 'find ~/ -type f -print0 | xargs -0 shred -u'
echo 'shred -u .bash_history'
echo 'shred -u .zsh_history'
echo 'Delete the keychain stuff'
echo 'Delete 1password stuff'


exit 0
