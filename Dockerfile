FROM --platform=linux/amd64 ubuntu:24.04

# ১. ল্যাঙ্গুয়েজ ও এনভায়রনমেন্ট ফিক্স
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Dhaka
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# প্রয়োজনীয় সব প্যাকেজ একবারে ইনস্টল
RUN apt update -y && apt install --no-install-recommends -y \
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
    locales \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    software-properties-common \
    openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Locale জেনারেট করা (ইংলিশ লক করার জন্য)
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# ফায়ারফক্স PPA সেটআপ (Ubuntu 24.04 Noble)
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:noble";' > /etc/apt/apt.conf.d/51unattended-upgrades-firefox

RUN apt update -y && apt install -y firefox xubuntu-icon-theme && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ২. GitHub থেকে noVNC এর লেটেস্ট ভার্সন ক্লোন (Modern UI ও মাউস ফিচারের জন্য)
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

# ৩. বিল্ড স্টেজে xstartup ফাইল তৈরি (এতে রেলওয়েতে কোন স্ক্রিপ্ট এরর হবে না)
RUN mkdir -p /root/.vnc && \
    echo '#!/bin/sh' > /root/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup && \
    echo 'export LANG=en_US.UTF-8' >> /root/.vnc/xstartup && \
    echo 'export LC_ALL=en_US.UTF-8' >> /root/.vnc/xstartup && \
    echo 'exec dbus-launch startxfce4 &' >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

# ৪. ক্লিন ও সলিড এক লাইনের CMD (যা ক্র্যাশ প্রুফ)
CMD ["bash", "-c", "rm -rf /tmp/.X*-lock /tmp/.X11-unix/X* || true && vncserver -localhost no -SecurityTypes None -geometry 1366x768 --I-KNOW-THIS-IS-INSECURE && openssl req -new -subj '/CN=localhost' -x509 -days 365 -nodes -out /tmp/self.pem -keyout /tmp/self.pem && websockify --web=/opt/novnc --cert=/tmp/self.pem 6080 localhost:5901"]
