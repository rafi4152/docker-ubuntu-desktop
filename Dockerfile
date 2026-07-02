FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Dhaka
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

RUN apt update && \
    apt install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    sudo \
    xterm \
    init \
    systemd \
    snapd \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    locales \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    python3 \
    python3-pip \
    software-properties-common \
    openssl

RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

RUN add-apt-repository ppa:mozillateam/ppa -y

RUN echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox

RUN echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:noble";' > /etc/apt/apt.conf.d/51unattended-upgrades-firefox

RUN apt update && apt install -y firefox xubuntu-icon-theme

RUN git clone https://github.com/novnc/noVNC.git /opt/novnc
RUN git clone https://github.com/novnc/websockify.git /opt/novnc/utils/websockify

RUN ln -s /opt/novnc/vnc.html /opt/novnc/index.html

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD bash -c '\
export LANG=en_US.UTF-8 && \
export LANGUAGE=en_US:en && \
export LC_ALL=en_US.UTF-8 && \
mkdir -p ~/.vnc && \
echo "#!/bin/sh\nstartxfce4" > ~/.vnc/xstartup && \
chmod +x ~/.vnc/xstartup && \
vncserver :1 -localhost no -SecurityTypes None -geometry 1366x768 --I-KNOW-THIS-IS-INSECURE && \
openssl req -new -x509 -days 365 -nodes -subj "/CN=localhost" -out /tmp/self.pem -keyout /tmp/self.pem && \
python3 /opt/novnc/utils/websockify/run --web /opt/novnc --cert /tmp/self.pem 6080 localhost:5901'
