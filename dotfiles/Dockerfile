FROM ubuntu
MAINTAINER Mike Christof <mhristof@gmail.com>

RUN apt-get update -y && \
  apt-get install -y make sudo ssh && \
  rm -rf /var/lib/apt/lists/*
RUN groupadd -g 999 dot && \
    useradd -m -s /bin/bash -r -u 999 -g dot dot &&\
    adduser dot sudo &&\
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER dot

