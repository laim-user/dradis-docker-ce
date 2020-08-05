#!/bin/bash

# Exit the script in case of errors
set -e

SECRET_KEY_BASE="${SECRET_KEY_BASE:-$(bundle exec rake secret)}"
export SECRET_KEY_BASE

RAILS_SERVE_STATIC_FILES="true"
export RAILS_SERVE_STATIC_FILES

cp -r -n /opt/dradis-ce/templates_orig/* /opt/dradis-ce/templates/
chown -R dradis-ce:dradis-ce /opt/dradis-ce/templates /opt/dradis-ce/attachments
chmod -R u+w /dbdata/ /opt/dradis-ce/templates /opt/dradis-ce/attachments

if [ "$RAILS_ENV" = "test" ]
then
  cp -n /opt/dradis-ce/db/test.sqlite3 /dbdata/
  chown -R dradis-ce:dradis-ce /dbdata/
  exec su -m -l dradis-ce -c 'bundle exec rails server -b 0.0.0.0'
elif [ "$RAILS_ENV" = "production" ]
then
  cp -n /opt/dradis-ce/db/production.sqlite3 /dbdata/
  chown -R dradis-ce:dradis-ce /dbdata/
  exec su -m -l dradis-ce -c 'exec bundle exec rake resque:work & bundle exec rails server -b 0.0.0.0'
else
  echo "Incorrect RAILS_ENV value: ${RAILS_ENV}"
fi
