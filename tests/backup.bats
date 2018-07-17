
@test "back up directory" {
    local root=/tmp/$RANDOM
    mkdir -p $root/1/2/3/4
    cd $root
    backup 1
    ls | grep "$(date +'%Y%m%d')"
    rm -rf $root
}

@test "backup single file" {
    local file=/tmp/$RANDOM
    date > $file
    cd $(dirname $file)
    backup $(basename $file)
    ls | grep "$(basename $file).$(date +'%Y%m%d')"
    rm -rf $file*
}

