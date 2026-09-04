FROM quay.io/fedora/fedora-bootc:44

# Install required packages
RUN dnf -y install \
    openssh-server \
    podman \
    fastfetch \
    && dnf clean all

# Configure sshd service to start on boot
RUN systemctl enable sshd.service

# Inject SSH Public Key for root user
ARG SSH_PUB_KEY
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    echo "${SSH_PUB_KEY}" > /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys