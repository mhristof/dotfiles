#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

for branch in $(glab api "/projects/:id/repository/branches" | jq -rc '.[]'); do
    committed_date=$(jq -r .commit.committed_date <<<"$branch" | cut -dT -f1)
    name=$(jq -r .name <<<"$branch")
    merged=$(jq -r .merged <<<"$branch")

    committed_date_age=$(python -c "from datetime import datetime as dt; print((dt.now() - dt.strptime('$committed_date', '%Y-%m-%d')).days)")

    if [[ $committed_date_age -lt 30 ]] && [[ $merged == "false" ]]; then
        continue
    fi

    name_url_encoded=$(python -c "import urllib.parse; print(urllib.parse.quote('$name', safe=''))")
    echo "branch: $name ($name_url_encoded), last commit: $committed_date, age: $committed_date_age"

    glab api "/projects/:id/repository/branches/$name_url_encoded" -X DELETE | cat
done

exit 0
