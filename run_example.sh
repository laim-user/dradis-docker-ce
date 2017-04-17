#!/bin/sh

mkdir -p dbdata/

docker run \
  -p 3000:3000 \
  --volume "$(pwd)/dbdata:/dbdata" \
  --link dradis-redis:redis \
  evait/dradis-ce "${@}"
