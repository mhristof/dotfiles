#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# set -euo pipefail

docker volume ls -qf dangling=true | xargs --no-run-if-empty docker volume rm
docker network ls | grep "bridge" | awk '/ / { print $1 }' | xargs --no-run-if-empty docker network rm
docker images --filter "dangling=true" -q --no-trunc | xargs --no-run-if-empty docker rmi
docker images | grep "none" | awk '/ / { print $3 }' | xargs --no-run-if-empty docker rmi
docker images -q | xargs --no-run-if-empty docker rmi -f
docker ps -qa --no-trunc --filter "status=exited" | xargs --no-run-if-empty docker rm

exit 0
