# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

ARG BUILD_DATE
ARG VERSION
ARG YANK_NOTE_VERSION=3.87.1

LABEL build_version="yank-note-docker ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="yank-note-docker"
LABEL org.opencontainers.image.title="Yank Note"
LABEL org.opencontainers.image.description="Yank Note - A highly extensible Markdown editor for KasmVNC"
LABEL org.opencontainers.image.source="https://github.com/purocean/yn"
LABEL org.opencontainers.image.version=${YANK_NOTE_VERSION}

ENV TITLE="Yank Note" \
    YANK_NOTE_VERSION=${YANK_NOTE_VERSION}

# download yank-note deb package and extract
# use curl (available in baseimage) instead of wget
RUN apt update && \
    apt install -y wget gdebi vim gnome-terminal dbus fcitx-rime fonts-wqy-microhei ttf-wqy-zenhei python3-xdg && \
    echo "**** download yank-note v${YANK_NOTE_VERSION} deb package ****" && \
    curl -L -f -s \
        "https://github.com/purocean/yn/releases/download/v${YANK_NOTE_VERSION}/Yank-Note-linux-amd64-${YANK_NOTE_VERSION}.deb" \
        -o /tmp/yank-note.deb && \
    echo "**** extract deb to /opt/yank-note ****" && \
    mkdir -p /opt/yank-note && \
    dpkg-deb -x /tmp/yank-note.deb /opt/yank-note && \
    rm -f /tmp/yank-note.deb

# install icon
RUN mkdir -p /usr/share/icons/hicolor/256x256/apps && \
    curl -L -f -s \
        "https://raw.githubusercontent.com/purocean/yn/v${YANK_NOTE_VERSION}/build/icon.png" \
        -o /usr/share/icons/hicolor/256x256/apps/yank-note.png || true

# create launcher with KasmVNC-compatible flags for running Electron in a container
RUN EXEC_CMD="/opt/yank-note/opt/'Yank Note'/yank-note" && \
    printf '#!/bin/bash\n' > /opt/yank-note/yank-note-launcher.sh && \
    printf 'exec %s \\\n' "$EXEC_CMD" >> /opt/yank-note/yank-note-launcher.sh && \
    printf '    --no-sandbox \\\n' >> /opt/yank-note/yank-note-launcher.sh && \
    printf '    --disable-gpu \\\n' >> /opt/yank-note/yank-note-launcher.sh && \
    printf '    --disable-software-rasterizer \\\n' >> /opt/yank-note/yank-note-launcher.sh && \
    printf '    --disable-dev-shm-usage \\\n' >> /opt/yank-note/yank-note-launcher.sh && \
    printf '    --disable-backgrounding-occluded-windows \\\n' >> /opt/yank-note/yank-note-launcher.sh && \
    printf '    --disable-background-timer-throttling \\\n' >> /opt/yank-note/yank-note-launcher.sh && \
    printf '    --disable-renderer-backgrounding \\\n' >> /opt/yank-note/yank-note-launcher.sh && \
    printf '    --disable-blink-features=AutomationControlled \\\n' >> /opt/yank-note/yank-note-launcher.sh && \
    printf '    "$@"\n' >> /opt/yank-note/yank-note-launcher.sh && \
    chmod +x /opt/yank-note/yank-note-launcher.sh && \
    chown -R abc:abc /opt/yank-note

# copy autostart and menu
COPY /root/ /

EXPOSE 3000

VOLUME /config
