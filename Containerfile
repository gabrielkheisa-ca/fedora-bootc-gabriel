FROM quay.io/fedora/fedora-coreos:stable

# Install your extra tools/packages
RUN dnf -y install \
    podman \
    fastfetch \
    && dnf clean all

# Declare build argument for static SSH key fallback
ARG SSH_PUB_KEY

# Set up SSH key in the FCOS root location
RUN mkdir -p /var/roothome/.ssh && \
    chmod 700 /var/roothome/.ssh && \
    printf "%s\n" "$SSH_PUB_KEY" > /var/roothome/.ssh/authorized_keys && \
    chmod 600 /var/roothome/.ssh/authorized_keys