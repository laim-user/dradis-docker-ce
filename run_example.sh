#!/bin/sh

mkdir -p dbdata/

docker run \
  -p 3000:3000 \
  --volume "$(pwd)/dbdata:/dbdata" \
  --volume "$(pwd)/templates:/opt/dradis/templates" \
  --link dradis-redis:redis \
  evait/dradis-ce "${@}"
