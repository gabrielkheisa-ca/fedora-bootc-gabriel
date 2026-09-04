FROM quay.io/fedora/fedora-bootc:44

# Install required packages (including GCP cloud & networking components)
RUN dnf -y install \
    openssh-server \
    podman \
    fastfetch \
    NetworkManager \
    google-guest-agent \
    afterburn \
    && dnf clean all

# Enable essential system services for GCP boot
RUN systemctl enable NetworkManager.service sshd.service google-guest-agent.service

# Declare build argument for SSH key
ARG SSH_PUB_KEY

# Set up static SSH keys for both core and root (GCP metadata will also manage keys dynamically via afterburn/guest-agent)
RUN mkdir -p /var/roothome/.ssh /var/home/core/.ssh && \
    chmod 700 /var/roothome/.ssh /var/home/core/.ssh && \
    printf "%s\n" "$SSH_PUB_KEY" > /var/roothome/.ssh/authorized_keys && \
    printf "%s\n" "$SSH_PUB_KEY" > /var/home/core/.ssh/authorized_keys && \
    chmod 600 /var/roothome/.ssh/authorized_keys /var/home/core/.ssh/authorized_keys && \
    chown -R 1000:1000 /var/home/core/.ssh