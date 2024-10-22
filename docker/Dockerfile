FROM archlinux:latest
LABEL maintainer="werew@ret2libc.com"

ARG USERNAME="werew"

EXPOSE 80/tcp

# Install essential packages
RUN pacman -Syu --noconfirm sudo vim tmux zsh git cmake curl ripgrep python python-pip wget

RUN echo 'root:root' | chpasswd
RUN echo '%wheel ALL=(ALL) ALL' >> /etc/sudoers

# Add user and copy some config files
RUN useradd -m -d "/home/$USERNAME" "$USERNAME" && \
    echo "$USERNAME:$USERNAME" | chpasswd && \
    usermod -aG wheel "$USERNAME"

ADD --chown=$USERNAME:$USERNAME dot_files/.* /home/$USERNAME/

# Some config
ENTRYPOINT ["/bin/zsh"]
WORKDIR "/home/$USERNAME"
USER "$USERNAME"

