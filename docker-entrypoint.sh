#!/bin/bash

# Exit the script in case of errors
set -e

SECRET_KEY_BASE="${SECRET_KEY_BASE:-$(bundle exec rake secret)}"
export SECRET_KEY_BASE
RAILS_SERVE_STATIC_FILES="true"
export RAILS_SERVE_STATIC_FILES

cp -n /opt/dradis-ce/db/production.sqlite3 /dbdata/
chown -R dradis-ce /dbdata/
chmod -R u+w /dbdata/

if [ -z "${*}" ]
then
  exec su -m -l dradis-ce -c 'exec bundle-2.3 exec rails server'
else
  exec su -m -l dradis-ce -c 'exec bundle-2.3 exec rails server "$0" "$@"' -- "${@}"
fi
