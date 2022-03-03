FROM ubuntu:20.04
# FROM nvcr.io/nvidia/pytorch:20.12-py3

RUN apt-get update &&  DEBIAN_FRONTEND="noninteractive" TZ="Europe/Zurich" apt-get install -y \
    curl \
    ca-certificates \
    sudo \
    git \
    bzip2 \
    libx11-6 \
    zip \
    unzip \
    ssh \
 && rm -rf /var/lib/apt/lists/*

USER root
RUN mkdir /opt/lab
COPY ../setup.sh /opt/lab/
RUN chmod -R a+x /opt/lab/

