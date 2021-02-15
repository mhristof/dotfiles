#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

ROW_LIMIT=10

while read -r line; do
    file=$(echo "$line" | awk '{print $2}')
    count=$(echo "$line" | awk '{print $1}')
    auth="$(git log --pretty=format:"%ae" -- "$file"  --all | sort | uniq -c | sort -n -r | xargs -n2  | tr '\n' ',')"

    echo "$count%$file%$auth"
done < <(git log --name-status "$@"		| \
    grep -E '^[A-Z]\s+'		| \
    cut -c3-500			| \
    sort				| \
    uniq -c				| \
    grep -vE '^ {6}1 '		| \
    sort -n	 -r | head -$ROW_LIMIT | xargs -n2
) | column -s '%' -t

exit 0
