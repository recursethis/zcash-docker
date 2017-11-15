#!/bin/sh
set -u

# wait for db to start up
sleep 10

# populate db
python manage.py makemigrations
python manage.py migrate

# healthcheck
python manage.py healthcheck

exec "$@"
