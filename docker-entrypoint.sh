#!/bin/bash

# Exit the script in case of errors
set -e

SECRET_KEY_BASE="${SECRET_KEY_BASE:-$(bundle exec rake secret)}"
export SECRET_KEY_BASE

cp -n /opt/dradis-ce/db/production.sqlite3 /dbdata/
chown -R dradis-ce /dbdata/
chmod -R u+w /dbdata/

if [ -z "${*}" ]
then
  exec su -m -l dradis-ce -c 'exec bundle exec rails server'
else
  exec su -m -l dradis-ce -c 'exec bundle exec rails server "$0" "$@"' -- "${@}"
fi
