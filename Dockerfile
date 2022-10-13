FROM python:3.9-alpine

RUN apk update \
    && apk add nginx vim
COPY nginx.default /etc/nginx/sites-available/default

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log


RUN mkdir -p /opt/app \
    && mkdir -p /opt/app/pip_cache \
    && mkdir -p /opt/app/DjangoProject

COPY dependancies.txt start-server.sh /opt/app/
RUN chmod a+x /opt/app/start-server.sh

RUN mkdir -p /opt/app/pip_cache/.pip_cache \
    && pip install -r /opt/app/dependancies.txt --cache-dir /opt/app/pip_cache \
    && chown -R nginx:nginx /opt/app

COPY src /opt/app/DjangoProject

WORKDIR /opt/app/DjangoProject

RUN python3 manage.py makemigrations \
    && python3 manage.py migrate \
    && python3 manage.py test > test-results.txt

ENV DJANGO_SUPERUSER_USERNAME admin
ENV DJANGO_SUPERUSER_PASSWORD admin
ENV DJANGO_SUPERUSER_EMAIL admin@example.com
ENV APP_SECRET_KEY secret

EXPOSE 8020

STOPSIGNAL SIGTERM

CMD ["/opt/app/start-server.sh"]