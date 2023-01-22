FROM ubuntu:20.04

# Importando pacotes do MongoDB
# https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/?_ga=2.22663293.775193578.1674019496-1715206182.1662002499#install-mongodb-community-edition

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \ 
    apt-get install -y wget gnupg

RUN wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list

# Instala mongodb backup tools
RUN DEBIAN_FRONTEND=noninteractive apt-get update && \ 
    apt-get install -y \
    mongodb-org-tools=6.0.3

# Instala AWS cli e p7zip
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    awscli \
    p7zip-full

WORKDIR /scripts

COPY backup-mongodb.sh .
RUN chmod +x backup-mongodb.sh

ENV MONGODB_URI="" \
    MONGODB_OPLOG="" \
    BUCKET_URI="" \
    AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_DEFAULT_REGION="" \
    S3_ENDPOINT_URL="" \
    PASSWORD_7ZIP=""

RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/apt/lists/*

CMD ["/scripts/backup-mongodb.sh"]
