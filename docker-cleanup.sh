#! /usr/bin/env bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
# set -euo pipefail

docker volume rm $(docker volume ls -qf dangling=true)
docker volume ls -qf dangling=true | xargs  docker volume rm
docker network rm $(docker network ls | grep "bridge" | awk '/ / { print $1 }')
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')
docker rm $(docker ps -qa --no-trunc --filter "status=exited")
docker rm $(docker ps -qa --no-trunc --filter "status=exited")

exit 0
