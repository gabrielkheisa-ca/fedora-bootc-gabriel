FROM quay.io/fedora/fedora-bootc:44

# Install required packages
RUN dnf -y install \
    openssh-server \
    podman \
    fastfetch \
    && dnf clean all

# Enable sshd service
RUN systemctl enable sshd.service

# Declare build argument for SSH key
ARG SSH_PUB_KEY

# Target /var/roothome/.ssh directly to accommodate bootc's symlinked /root
RUN mkdir -p /var/roothome/.ssh && \
    chmod 700 /var/roothome/.ssh && \
    printf "%s\n" "$SSH_PUB_KEY" > /var/roothome/.ssh/authorized_keys && \
    chmod 600 /var/roothome/.ssh/authorized_keys