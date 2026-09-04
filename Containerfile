FROM quay.io/fedora/fedora-bootc:44

# Install required packages
RUN dnf -y install \
    openssh-server \
    podman \
    fastfetch \
    && dnf clean all

# Enable sshd
RUN systemctl enable sshd.service

# Declare ARG AFTER 'FROM' so it's in scope for the build
ARG SSH_PUB_KEY

# Inject key safely using printf
RUN mkdir -p /root/.ssh && \
    chmod 700 /root/.ssh && \
    printf "%s\n" "$SSH_PUB_KEY" > /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys