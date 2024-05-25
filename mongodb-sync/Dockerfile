FROM ubuntu:20.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \ 
    apt-get install -y curl libgssapi-krb5-2 && \
    apt-get autoremove --yes && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/*

# Download mongosync    
RUN curl -o mongosync.tgz https://fastdl.mongodb.org/tools/mongosync/mongosync-ubuntu2004-x86_64-1.7.2.tgz && \
    mkdir -p /mongosync && \ 
    tar -zxvf mongosync.tgz -C /mongosync --strip-components=1 && \
    rm mongosync.tgz

# Instala mongosync
RUN cp /mongosync/bin/mongosync /usr/local/bin/

WORKDIR /scripts

COPY *.sh .

RUN chmod +x mongosync.sh
RUN chmod +x start.sh
RUN chmod +x pause.sh
RUN chmod +x resume.sh
RUN chmod +x progress.sh
RUN chmod +x commit.sh

ENV CLUSTER0_URI="" \
    CLUSTER1_URI="" \
    LOAD_LEVEL="3" \
    VERBOSITY="DEBUG" \
    DISABLE_TELEMETRY="false"

ENTRYPOINT ["/scripts/mongosync.sh"]

EXPOSE 27182