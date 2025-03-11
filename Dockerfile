FROM ubuntu:noble

ENV HOME=/root
ENV LC_ALL=C.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

RUN apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        python3 python-is-python3 xvfb x11vnc novnc websockify xdotool wget tar xz-utils supervisor net-tools fluxbox gnupg2 ca-certificates; \
    rm -rf /var/lib/apt/lists/*

RUN dpkg --add-architecture i386; \
    mkdir -p /etc/apt/keyrings; \
    wget -q -O - https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -; \
    wget -q -O /etc/apt/sources.list.d/winehq-noble.sources https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        winehq-stable=10.0.0.0~noble-1; \
    rm -rf /var/lib/apt/lists/*

ENV WINEPREFIX=/root/prefix32
ENV WINEARCH=win32
ENV DISPLAY=:0

RUN mkdir -p /opt/wine/mono; \
    wget -q -O - https://dl.winehq.org/wine/wine-mono/9.4.0/wine-mono-9.4.0-x86.tar.xz \
        | tar -xJ -C /opt/wine/mono; \
    mkdir -p /opt/wine/gecko; \
    wget -q -O - https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86.tar.xz \
        | tar -xJ -C /opt/wine/gecko; \
    wget -q -O - https://dl.winehq.org/wine/wine-gecko/2.47.4/wine-gecko-2.47.4-x86_64.tar.xz \
        | tar -xJ -C /opt/wine/gecko

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supervisord-wine.conf /etc/supervisor/conf.d/supervisord-wine.conf

COPY index.html /usr/share/novnc/index.html

EXPOSE 8080

CMD ["/usr/bin/supervisord"]
