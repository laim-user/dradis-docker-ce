#!/bin/sh

docker build \
  --rm \
  --force-rm \
  "${@}" \
  -t laim/dradis-ce .
