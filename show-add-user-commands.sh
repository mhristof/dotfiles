#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

die() {
    echo "$*" 1>&2
    exit 1
}

user=$(cut -d "|" -f1 <<<"$1")
key=$(cut -d "|" -f2 <<<"$1")

if [[ -z $user ]]; then
    die "Error, user is not defined [$1]"
fi

if [[ -z "$key" ]]; then
    die "Error, key is not defined [$1]"
fi

case $user in
    *@*)
        user=${user%@*}
        ;;
esac

cat <<EOF
useradd --create-home $user
mkdir /home/$user/.ssh/
echo "$key" >/home/$user/.ssh/authorized_keys
chown -R $user:$user /home/$user/
usermod -aG sudo $user
find /home/$user | xargs ls -ald
EOF

exit 0
