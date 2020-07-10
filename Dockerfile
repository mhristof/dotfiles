FROM ubuntu:20.04

ENV XDG_CACHE_HOME /tmp/.cache
ENV PYTEST_ADDOPTS="-o cache_dir=/tmp"
ENV PYLINTHOME=/tmp

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && \
  apt-get install --yes --no-install-recommends \
    curl \
    ca-certificates \
    git \
    gcc \
    make && \
  rm -rf /var/lib/apt/lists/*

ENV PATH /home/mhristof/.brew/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN curl --silent https://github.com/tianon/gosu/releases/download/1.12/gosu-amd64 -L > /usr/bin/gosu &&\
    chown root:users /usr/bin/gosu &&\
    chmod +x /usr/bin/gosu &&\
    chmod +s /usr/bin/gosu &&\
    echo '#!/usr/bin/env bash' > /usr/bin/sudo &&\
    echo 'gosu root $@' >> /usr/bin/sudo &&\
    chmod 0755 /usr/bin/sudo

RUN groupadd -g 999 mhristof && \
    useradd -r -u 999 -g mhristof -g users --create-home --home /home/mhristof mhristof

COPY . /home/mhristof/dotfiles
WORKDIR /home/mhristof/dotfiles
RUN chown mhristof:mhristof -R /home/mhristof/

USER mhristof
