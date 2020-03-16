# Docker in Docker is required for inspec to connect to
# another container running in the context of a CI Job
FROM ubuntu:18.04

RUN echo "Install base dependencies" && \
    apt-get -y update && \
    apt-get -y install \
      apt-transport-https \
      build-essential \
      ca-certificates \
      curl \
      software-properties-common && \
    echo "Install Docker dependencies" && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" && \
    apt-get -y update && \
    apt-get -y install \
      docker-ce \
      curl \
      wget \
      python3 \
      python-pip && \ 
    curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod 0755 /usr/local/bin/docker-compose

WORKDIR /
COPY . stack 
