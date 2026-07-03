FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install --no-install-recommends -y \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify sudo xterm init systemd snapd vim net-tools curl wget git tzdata \
    dbus-x11 x11-utils x11-xserver-utils x11-apps \
    software-properties-common \
    ca-certificates gnupg \
    libnss3 libu2f-udev xdg-utils \
    libasound2 libatk-bridge2.0-0 libatk1.0-0 libdbus-1-3 libdrm2 libgbm1 libgtk-3-0 libnspr4 \
    libx11-xcb1 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libxss1 libxtst6 libxcb1 \
    fonts-liberation

RUN add-apt-repository ppa:mozillateam/ppa -y
RUN echo 'Package: *' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin: release o=LP-PPA-mozillateam' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Pin-Priority: 1001' >> /etc/apt/preferences.d/mozilla-firefox
RUN echo 'Unattended-Upgrade::Allowed-Origins:: "LP-PPA-mozillateam:jammy";' | tee /etc/apt/apt.conf.d/51unattended-upgrades-firefox

RUN apt update -y && apt install -y firefox
RUN apt update -y && apt install -y xubuntu-icon-theme

RUN touch /root/.Xauthority

EXPOSE 5901
EXPOSE 6080

CMD bash -c "vncserver -localhost no -SecurityTypes None -geometry 1024x768 --I-KNOW-THIS-IS-INSECURE && openssl req -new -subj \"/C=JP\" -x509 -days 365 -nodes -out self.pem -keyout self.pem && websockify -D --web=/usr/share/novnc/ --cert=self.pem 6080 localhost:5901 && tail -f /dev/null"
