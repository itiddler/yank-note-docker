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

# install tools for appimage extraction
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        squashfs-tools \
        wget \
    && rm -rf /var/lib/apt/lists/* /tmp/*

# download and extract yank-note appimage
# the appimage is a self-extracting ELF; --appimage-extract extracts to ./squashfs-root/
RUN echo "**** download yank-note v${YANK_NOTE_VERSION} appimage ****" && \
    wget -q "https://github.com/purocean/yn/releases/download/v${YANK_NOTE_VERSION}/Yank-Note-linux-x86_64-${YANK_NOTE_VERSION}.AppImage" \
        -O /tmp/yank-note.AppImage && \
    chmod +x /tmp/yank-note.AppImage && \
    echo "**** extract appimage ****" && \
    mkdir -p /opt/yank-note && \
    cd /opt/yank-note && \
    /tmp/yank-note.AppImage --appimage-extract && \
    mv squashfs-root/* . && \
    rmdir squashfs-root && \
    rm -f /tmp/yank-note.AppImage

# install icon
RUN mkdir -p /usr/share/icons/hicolor/256x256/apps && \
    wget -q "https://raw.githubusercontent.com/purocean/yn/v${YANK_NOTE_VERSION}/build/icon.png" \
        -O /usr/share/icons/hicolor/256x256/apps/yank-note.png || true

# create launcher with KasmVNC-compatible flags for running Electron in a container
RUN printf '#!/bin/bash\n' > /opt/yank-note/yank-note-launcher.sh && \
    printf 'exec /opt/yank-note/AppRun \\\n' >> /opt/yank-note/yank-note-launcher.sh && \
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
