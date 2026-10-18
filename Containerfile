FROM quay.io/fedora/fedora-coreos:stable

ARG SSH_PUB_KEY

# 1. Install desktop environment, Chromium, xRDP, and explicit Xfce core packages
RUN dnf -y install \
    podman \
    fastfetch \
    chromium \
    xrdp \
    xorgxrdp \
    xorg-x11-server-Xorg \
    dbus-x11 \
    @xfce-desktop-environment \
    xfce4-session \
    xfce4-panel \
    xfce4-settings \
    xfwm4 \
    xfce4-terminal \
    && dnf clean all

# 2. Configure DBus-wrapped Xfce startup session for system, core, and root
RUN printf '#!/bin/bash\nexport XDG_SESSION_TYPE=x11\nexport XDG_CURRENT_DESKTOP=XFCE\nexport DESKTOP_SESSION=xfce\nif [ -f /usr/bin/dbus-run-session ]; then\n  exec dbus-run-session startxfce4\nelse\n  exec startxfce4\nfi\n' > /etc/skel/.Xclients && \
    chmod +x /etc/skel/.Xclients && \
    mkdir -p /var/home/core && \
    cp /etc/skel/.Xclients /var/home/core/.Xclients && \
    chmod +x /var/home/core/.Xclients && \
    mkdir -p /var/roothome && \
    cp /etc/skel/.Xclients /var/roothome/.Xclients && \
    chmod +x /var/roothome/.Xclients

# 3. Fix xRDP PAM configuration (remove obsolete pam_lastlog.so from Fedora)
RUN sed -i '/pam_lastlog.so/d' /etc/pam.d/xrdp-sesman

# 4. Safely configure firewall port 3389
RUN firewall-offline-cmd --add-port=3389/tcp

# 5. Enable xRDP systemd services on boot
RUN systemctl enable xrdp xrdp-sesman

# 6. Configure SSH keys for core and root users
RUN mkdir -p /var/home/core/.ssh /var/roothome/.ssh && \
    chmod 700 /var/home/core/.ssh /var/roothome/.ssh && \
    if [ -n "$SSH_PUB_KEY" ]; then \
        printf "%s\n" "$SSH_PUB_KEY" > /var/home/core/.ssh/authorized_keys && \
        printf "%s\n" "$SSH_PUB_KEY" > /var/roothome/.ssh/authorized_keys && \
        chmod 600 /var/home/core/.ssh/authorized_keys /var/roothome/.ssh/authorized_keys; \
    fi && \
    chown -R 1000:1000 /var/home/core

# 7. Set password and unlock accounts securely via BuildKit secret mount
RUN --mount=type=secret,id=ROOT_PASSWORD \
    if [ -f /run/secrets/ROOT_PASSWORD ]; then \
        PASS=$(tr -d '\r\n' < /run/secrets/ROOT_PASSWORD); \
        echo "core:${PASS}" | chpasswd; \
        echo "root:${PASS}" | chpasswd; \
        usermod -U core || true; \
        usermod -U root || true; \
    fi