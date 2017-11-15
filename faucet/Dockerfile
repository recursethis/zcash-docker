FROM python:2.7.14-jessie
MAINTAINER recursethis

# install faucet
RUN apt-get update && apt-get -y install \
    postgresql-contrib libpq-dev \
    python-psycopg2 fail2ban git

ENV FAUCET_DIR /home/zcash/faucet
ENV DB_HOST db
ENV DJANGO_SECRET_KEY mysecretkey
ENV DJANGO_POSTGRESQL_PASSWORD mysecretpassword
ENV DJANGO_ENVIRONMENT prod

EXPOSE 8000

WORKDIR $FAUCET_DIR

# install faucet
RUN git clone https://github.com/zcash/zfaucet $FAUCET_DIR \
    && mkdir -p $FAUCET_DIR/lib \
    && chmod 0755 $FAUCET_DIR/lib \
    && cd $FAUCET_DIR/lib \
    && git clone https://github.com/arcalinea/pyZcash \
    && cd .. && ln -s lib/pyZcash/pyZcash pyZcash \
    && pip install -r requirements.txt \
    && pip install -r requirements-prod.txt

# fix settings to work with docker
RUN sed -i "s/^SECRET_KEY.*$/SECRET_KEY = os.getenv\('DJANGO_SECRET_KEY'\)/" zfaucet/settings.py \
    && sed -i "s/^DJANGO_POSTGRESQL_PASSWORD.*$/DJANGO_POSTGRESQL_PASSWORD = os.getenv\('DJANGO_POSTGRESQL_PASSWORD'\)/" zfaucet/settings.py \
    && sed -i "s/'HOST'.*$/'HOST': os.getenv\('DB_HOST'\),/" zfaucet/settings.py \
    && sed -i "s/ALLOWED_HOSTS.*$/ALLOWED_HOSTS = \['faucet.testnet.z.cash', '127.0.0.1', os.getenv\('DOCKER_IP'\)\]/" zfaucet/settings.py \
    && echo "DEBUG=True" >> zfaucet/settings.py \
    && sed -i "s/localhost/zcashd/g" pyZcash/settings.py \
    && echo "yes" | python manage.py collectstatic

ENV DOCKER_IP 192.168.99.100

COPY init.sh /docker-entrypoint
RUN chmod +x /docker-entrypoint

ENTRYPOINT ["/docker-entrypoint"]
CMD ["gunicorn", "-b", "0.0.0.0:8000", "--workers=2", "--log-level", "debug", "zfaucet.wsgi" ]
