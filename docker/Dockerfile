FROM ubuntu:latest
LABEL maintainer="werew@ret2libc.com"

ARG USERNAME="werew"

# https://askubuntu.com/questions/909277/avoiding-user-interaction-with-tzdata-when-installing-certbot-in-a-docker-contai
ENV DEBIAN_FRONTEND=noninteractive

EXPOSE 80/tcp

# Add user and copy some config files
RUN useradd -m -d "/home/$USERNAME" "$USERNAME" && \
    echo "$USERNAME\n$USERNAME" | passwd "$USERNAME" && \
    usermod -aG sudo "$USERNAME"


ADD --chown=$USERNAME:$USERNAME resources/.* /home/$USERNAME/

# Install essential packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update -yq
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yq sudo vim tmux zsh git cmake curl ripgrep gdb python3 pip wget

# Radare
RUN git clone https://github.com/radareorg/radare2 && cd radare2 && sys/install.sh

# GEF
RUN bash -c "$(curl -fsSL https://gef.blah.cat/sh)"


# Some config
ENTRYPOINT ["/bin/zsh"]
WORKDIR "/home/$USERNAME"
USER "$USERNAME"

