ARG UBUNTU_CODENAME="noble"
FROM ubuntu:${UBUNTU_CODENAME}

ENV HOME="/root"
ENV LC_ALL="C.UTF-8"
ENV LANG="en_US.UTF-8"
ENV LANGUAGE="en_US.UTF-8"

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        python3 python-is-python3 xvfb x11vnc novnc websockify xdotool curl wget tar xz-utils supervisor net-tools fluxbox gpg ca-certificates locales winetricks zenity cabextract terminator; \
    locale-gen; \
    rm -rf /var/lib/apt/lists/*

ARG WINE_BRANCH="staging"
ARG WINE_VERSION="10.13"
ARG UBUNTU_CODENAME
RUN dpkg --add-architecture i386; \
    mkdir -p /etc/apt/keyrings; \
    wget -q -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -; \
    wget -q -O "/etc/apt/sources.list.d/winehq-${UBUNTU_CODENAME}.sources" "https://dl.winehq.org/wine-builds/ubuntu/dists/${UBUNTU_CODENAME}/winehq-${UBUNTU_CODENAME}.sources"; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        "winehq-${WINE_BRANCH}=${WINE_VERSION}~*"; \
    rm -rf /var/lib/apt/lists/*

ENV WINE_HOME="/opt/wine-${WINE_BRANCH}"
ENV WINEPREFIX="/root/prefix32"
ENV WINEARCH="win32"
ENV DISPLAY=":0"

ARG DOCKER_WINE_VERSION="6284e6ab06aef285263d1f77a5b1554afb1e83d9"
RUN wget -q -O- "https://raw.githubusercontent.com/scottyhardy/docker-wine/${DOCKER_WINE_VERSION}/download_gecko_and_mono.sh" \
    | bash -s -- "${WINE_VERSION}"

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supervisord-wine.conf /etc/supervisor/conf.d/supervisord-wine.conf

COPY index.html /usr/share/novnc/index.html

EXPOSE 8080

CMD ["/usr/bin/supervisord"]
