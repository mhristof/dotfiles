#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

if [[ ! -d "$1" ]]; then
    echo Error, argument is not a folder
fi
folder=$(basename $(readlink -f "$1"))


dest="$(pwd)/$folder.alfredsnippets"
echo Generating package for folder $folder. Destination $dest
rm $dest

cd $1
zip -r $dest *
cp $dest $(dirname $dest)/$(basename $dest .alfredsnippets).zip

exit 0
