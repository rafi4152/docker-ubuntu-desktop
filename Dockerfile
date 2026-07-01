FROM --platform=linux/amd64 ubuntu:26.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Dhaka

RUN apt-get update -y && \
    apt-get install --no-install-recommends -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    sudo \
    xterm \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    software-properties-common \
    xubuntu-icon-theme \
    ca-certificates \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Install Google Chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb || apt-get -f install -y && \
    rm -f google-chrome-stable_current_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD bash -lc 'mkdir -p /root/.vnc && \
printf "password\npassword\n\n" | vncpasswd && \
cat > /root/.vnc/xstartup <<EOF
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
exec startxfce4
EOF
chmod +x /root/.vnc/xstartup && \
vncserver :1 -localhost no -geometry 1366x768 -SecurityTypes VncAuth && \
websockify -D --web=/usr/share/novnc/ 6080 localhost:5901 && \
tail -f /dev/null'
