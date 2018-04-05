#!/usr/bin/env bats
# :vi ft=bash:
#
#
#

case $(uname) in
    Darwin)
        grep=ggrep
        ;;
esac

@test "dry run can specify its own file" {
    out=/tmp/test.$RANDOM.json
    ./profiles.py -n $out
    [ -f $out ]
}

@test "dry run produces a valid json" {
    out=/tmp/test.$RANDOM.json
    ./profiles.py -n $out
    cat $out | jq . > /dev/null
}


@test "test profile with cmd" {
    out=/tmp/test.$RANDOM.json
    config=/tmp/$RANDOM
    cat << EOF > $config
command1:
    cmd: 'date'
EOF
    ./profiles.py -n $out -c $config
    cat $out | jq -r '.Profiles[0]["Initial Text"]' | $grep -oP "^date$"
}
