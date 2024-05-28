FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Importando pacotes do MongoDB
# https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/#install-mongodb-community-edition

RUN apt-get update && \
    apt-get install -y gnupg curl && \   
    apt-get clean

RUN curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor

RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Instala mongodb backup tools, AWS cli e p7zip
RUN apt-get update && \ 
    apt-get install -y mongodb-org-tools=7.0.8 awscli p7zip-full && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /scripts

COPY backup.sh .
RUN chmod +x backup.sh

ENV MONGODB_URI="" \
    MONGODB_RESTORE_URI="" \
    MONGODB_OPLOG="" \
    BUCKET_URI="" \
    AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_DEFAULT_REGION="" \
    S3_ENDPOINT_URL="" \
    PASSWORD_7ZIP=""

CMD ["/scripts/backup.sh"]
