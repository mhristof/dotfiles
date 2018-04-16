@test "test help message" {
    ./ip2url.sh -h
}

@test "find the correct ip" {
    local ip='10.20.30.42'
    ./ip2url.sh -i "$ip" -n -H | grep "$ip"
}

@test "list options" {
    ./ip2url.sh -L | grep 'haproxy'
}

@test "check that options are resolvable" {
    for opt in $(./ip2url.sh -L); do
        ./ip2url.sh --$opt -i '10.20.30.14' -n
        echo $opt
    done
}
