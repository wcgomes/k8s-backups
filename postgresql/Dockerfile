FROM ubuntu:24.04

ARG TARGETARCH

ENV DEBIAN_FRONTEND=noninteractive

# Importando pacotes do Postgresql
# https://www.postgresql.org/download/linux/ubuntu/

RUN apt-get update && \
    apt-get install -y gnupg curl postgresql-common && \ 
    apt-get clean

RUN /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y

# Instala Postgresql, p7zip e unzip
RUN apt-get update && \
    apt-get install -y postgresql-18 p7zip-full unzip && \
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