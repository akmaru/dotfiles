FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV PYTHONIOENCODING=utf-8

RUN apt-get update && apt-get install -y --no-install-recommends \
  git \
  sudo \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

ARG USERNAME=developer
ARG GROUPNAME=developer
ARG UID=1000
ARG GID=1000
ARG PASSWORD=developer
RUN groupadd -g "$GID" "$GROUPNAME" \
  && useradd -m -s /bin/bash -u $UID -g $GID -G sudo $USERNAME \
  && echo $USERNAME:$PASSWORD | chpasswd  \
  && echo "$USERNAME   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
  && echo 'Defaults exempt_group = sudo' >> /etc/sudoers
USER $USERNAME
