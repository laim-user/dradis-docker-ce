#!/bin/sh

docker build \
  --rm \
  --force-rm \
  "${@}" \
  -t evait/dradis-ce .
