FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Importando pacotes do Postgresql
# https://www.postgresql.org/download/linux/ubuntu/

RUN apt-get update && \
    apt-get install -y gnupg postgresql-common && \ 
    apt-get clean

RUN /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y

# Instala Postgresql, AWS cli e p7zip
RUN apt-get update && \
    apt-get install -y postgresql-16 awscli p7zip-full && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /scripts

COPY backup.sh .
RUN chmod +x backup.sh

ENV PG_HOST="" \
    PG_RESTORE_HOST="" \
    PG_PORT="" \
    PG_DATABASE="" \
    PG_USER="" \
    PG_PASSWORD="" \
    BUCKET_URI="" \
    AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_DEFAULT_REGION="" \
    S3_ENDPOINT_URL="" \
    PASSWORD_7ZIP=""

CMD ["/scripts/backup.sh"]
