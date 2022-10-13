#!/bin/sh
ls -l
if [ -n "$DJANGO_SUPERUSER_USERNAME" ] && [ -n "$DJANGO_SUPERUSER_PASSWORD" ] ; then
    (python3 manage.py createsuperuser --no-input)
fi
(gunicorn Project.wsgi --user nginx --bind 0.0.0.0:8020 --workers 3) &
nginx -g "daemon off;"