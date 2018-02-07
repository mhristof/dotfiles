#! /usr/bin/env bash
#
# pbformat.sh
# Copyright (C) 2017 mhristof <mhristof@Mikes-MacBook-Pro-2.local>
#
# Distributed under terms of the MIT license.
#

PATH=$PATH:/usr/local/bin:/usr/local/opt/coreutils/libexec/gnubin
LOG=/tmp/log
OUT=/tmp/$(basename $0)
CACHE=$OUT.cache
CHECKSUM=$(pbpaste | md5sum - | cut -d ' ' -f1)
CLIPBOARD=$OUT.clipboard

while getopts "o:" OPTION
do
     case $OPTION in
         o) OUTPUT=$OPTARG
             ;;
     esac
done

pbpaste | grep 'failed": true' &> /dev/null && {
    # ansible playbook errors
    echo $(date) formating for ansible error >> $LOG
    pbpaste > $CLIPBOARD
    pbpaste >> /tmp/log

    pbpaste | perl -p -e 's/.*=>//g' | jq . &> $OUT
    if diff $CLIPBOARD $OUT &> /dev/null; then
        echo Clipboard not updated >> $LOG
    else
        echo >> $LOG
        echo Updating clipboard >> $LOG
        cat $OUT | pbcopy
        echo Updating cache $CHECKSUM $CACHE >> $LOG
        echo $CHECKSUM >> $CACHE
        sort -u $CACHE > $CACHE.new
        mv $CACHE.new $CACHE
    fi
}

pbpaste | ggrep -P 'https.*github.com.*pull/\d*$' &> /dev/null && {
    echo $(date) formating $(pbpaste) github url format:$OUTPUT >> $LOG
    pr=$(pbpaste | ggrep -oP '\d*')
    echo "[$pr|$(pbpaste)]" | pbcopy
}

#rm -rf $OUT $OUT.clipboard
exit 0
