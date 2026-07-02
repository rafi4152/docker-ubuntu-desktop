FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Dhaka
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV DISPLAY=:1
ENV VNC_GEOMETRY=1366x768
ENV VNC_DEPTH=24

RUN apt-get update && apt-get install -y --no-install-recommends \
    locales \
    tzdata \
    ca-certificates \
    sudo \
    curl \
    wget \
    git \
    gnupg \
    software-properties-common \
    dbus-x11 \
    xfce4 \
    xfce4-goodies \
    xfce4-terminal \
    tigervnc-standalone-server \
    novnc \
    websockify \
    yaru-theme-gtk \
    yaru-theme-icon \
    gnome-themes-extra \
    fonts-dejavu-core \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i 's/^# *en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen en_US.UTF-8

RUN add-apt-repository ppa:mozillateam/ppa -y && \
    printf 'Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001\n' > /etc/apt/preferences.d/mozilla-firefox && \
    apt-get update && \
    apt-get install -y --no-install-recommends firefox && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc && \
    printf '#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec dbus-launch --exit-with-session startxfce4\n' > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

RUN printf '#!/bin/bash\nset -e\ntrap '\''vncserver -kill :1 || true'\'' EXIT\nexport LANG=en_US.UTF-8\nexport LANGUAGE=en_US:en\nexport LC_ALL=en_US.UTF-8\nvncserver :1 -geometry "${VNC_GEOMETRY}" -depth "${VNC_DEPTH}" -localhost no -SecurityTypes None\nexec websockify --web=/usr/share/novnc/ 6080 localhost:5901\n' > /usr/local/bin/start-desktop.sh && \
    chmod +x /usr/local/bin/start-desktop.sh

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD ["/usr/local/bin/start-desktop.sh"]
