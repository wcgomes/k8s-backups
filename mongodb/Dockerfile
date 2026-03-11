FROM ubuntu:24.04

ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

# Importando pacotes do MongoDB
# https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/#install-mongodb-community-edition

RUN apt-get update && \
    apt-get install -y gnupg curl && \   
    apt-get clean

RUN curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg --dearmor

RUN echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/8.2 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-8.2.list

# Instala mongodb backup tools, p7zip e unzip
RUN apt-get update && \ 
    apt-get install -y mongodb-org-tools=8.2.0 p7zip-full unzip && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Instala AWS CLI v2
RUN if [ "$TARGETARCH" = "amd64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"; \
    elif [ "$TARGETARCH" = "arm64" ]; then \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"; \
    fi && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip aws/

# Instala kubectl
RUN ARCH=$(if [ "$TARGETARCH" = "arm64" ]; then echo "arm64"; else echo "amd64"; fi) && \
    curl -LO "https://dl.k8s.io/release/v1.35.0/bin/linux/${ARCH}/kubectl" && \
    curl -LO "https://dl.k8s.io/release/v1.35.0/bin/linux/${ARCH}/kubectl.sha256" && \
    echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

WORKDIR /scripts

COPY backup.sh .
RUN chmod +x backup.sh

ENV MONGODB_URI="" \
    MONGODB_RESTORE_URI="" \
    MONGODB_OPLOG="" \
    MONGODB_CONVERTLEGACYINDEXES_FLAG="" \
    MONGODB_NOINDEXRESTORE_FLAG="" \
    BUCKET_URI="" \
    AWS_ACCESS_KEY_ID="" \
    AWS_SECRET_ACCESS_KEY="" \
    AWS_DEFAULT_REGION="" \
    S3_ENDPOINT_URL="" \
    PASSWORD_7ZIP=""

CMD ["/scripts/backup.sh"]
