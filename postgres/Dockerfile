FROM ubuntu:20.04

# Importando pacotes do Postgres
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \ 
    apt-get install -y gnupg

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ focal"-pgdg main | tee  /etc/apt/sources.list.d/pgdg.list
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7FCC7D46ACCC4CF8

# Instala mongodb Postgres
RUN DEBIAN_FRONTEND=noninteractive apt-get update 
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql-15

RUN service postgresql start

# Instala AWS cli e p7zip
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    awscli \
    p7zip-full

WORKDIR /scripts

COPY backup.sh .
RUN chmod +x backup.sh

ENV PG_HOST="" \
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

RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/apt/lists/*

CMD ["/scripts/backup.sh"]
