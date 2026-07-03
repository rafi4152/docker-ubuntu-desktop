FROM --platform=linux/amd64 ubuntu:24.04

# ১. সিস্টেম ল্যাঙ্গুয়েজ সম্পূর্ণ ইংরেজি (English) ফিক্স করা
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Dhaka
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# প্রয়োজনীয় প্যাকেজ ইনস্টল (এখানে apt থেকে novnc বাদ দেওয়া হয়েছে)
RUN apt update && \
    apt install -y --no-install-recommends \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
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
    python3 \
    python3-pip \
    software-properties-common \
    openssl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Locale জেনারেট করা যেন ভাষা চেঞ্জ না হয়
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# ফায়ারফক্স PPA সেটআপ (উবুন্টু ২৪-এর noble ভার্সন)
RUN add-apt-repository ppa:mozillateam/ppa -y && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox && \
    echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:noble";' > /etc/apt/apt.conf.d/51unattended-upgrades-firefox

RUN apt update && apt install -y firefox xubuntu-icon-theme && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# ২. GitHub থেকে noVNC এবং Websockify-এর একদম লেটেস্ট ভার্সন ডাউনলোড
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc && \
    git clone https://github.com/novnc/websockify.git /opt/novnc/utils/websockify && \
    ln -s /opt/novnc/vnc.html /opt/novnc/index.html

RUN touch /root/.Xauthority

# পোর্ট এক্সপোজ
EXPOSE 5901
EXPOSE 6080

# ৩. ফাইনাল কমান্ড (লক ক্লিয়ারেন্স, ইংলিশ এনভায়রনমেন্ট এবং লেটেস্ট noVNC রান)
CMD bash -c '\
export LANG=en_US.UTF-8 && \
export LANGUAGE=en_US:en && \
export LC_ALL=en_US.UTF-8 && \
rm -rf /tmp/.X*-lock /tmp/.X11-unix/X* || true && \
mkdir -p ~/.vnc && \
printf "#!/bin/sh\nexport LANG=en_US.UTF-8\nexport LC_ALL=en_US.UTF-8\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec dbus-launch startxfce4 &\n" > ~/.vnc/xstartup && \
chmod +x ~/.vnc/xstartup && \
vncserver :1 -localhost no -SecurityTypes None -geometry 1366x768 --I-KNOW-THIS-IS-INSECURE && \
openssl req -new -x509 -days 365 -nodes -subj "/CN=localhost" -out /tmp/self.pem -keyout /tmp/self.pem && \
/opt/novnc/utils/websockify/run --web /opt/novnc --cert /tmp/self.pem 6080 localhost:5901'
