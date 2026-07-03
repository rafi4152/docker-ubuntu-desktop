FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Dhaka

# ১. প্রয়োজনীয় সব প্যাকেজ একবারে ইনস্টল করা
RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
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
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    software-properties-common \
    openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ২. লেটেস্ট উবুন্টুর জন্য ফায়ারফক্স PPA সেটআপ (noble কোডনেম সহ)
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:noble";' > /etc/apt/apt.conf.d/51unattended-upgrades-firefox

RUN apt update -y && apt install -y firefox xubuntu-icon-theme && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

# ৩. ফিক্সড এবং ক্র্যাশ-প্রুফ CMD কমান্ড
CMD ["bash", "-c", "rm -rf /tmp/.X*-lock /tmp/.X11-unix/X* || true && vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && openssl req -new -subj '/C=JP' -x509 -days 365 -nodes -out /tmp/self.pem -keyout /tmp/self.pem && websockify -D --web=/usr/share/novnc/ --cert=/tmp/self.pem 6080 localhost:5901 && tail -f /dev/null"]
