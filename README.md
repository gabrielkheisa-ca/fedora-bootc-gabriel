# Fedora Bootc Gabriel

Custom bootable container image based on [Fedora bootc](https://containers.github.io/bootc/) (`quay.io/fedora/fedora-bootc:44`). This repository provides a containerized bootable operating system image configured with SSH access, container runtime tools, and system diagnostic utilities.

## Features

- **Base Image:** `quay.io/fedora/fedora-bootc:44`
- **Pre-installed Packages:**
  - `openssh-server` - Remote SSH access
  - `podman` - OCI container runtime
  - `fastfetch` - System information display tool
- **System Services:** `sshd.service` enabled by default at boot
- **Security:** Root SSH public key injection at build time via the `SSH_PUB_KEY` argument

## Repository Structure

```
.
├── Containerfile                  # OCI image definition for the bootc system
├── .dockerignore                  # Files excluded from container build context
├── .gitignore                     # Files ignored by Git
└── .github/
    └── workflows/
        └── build-bootc.yml        # GitHub Actions CI/CD workflow
```

## Getting Started

### Prerequisites

- [Podman](https://podman.io/) or [Docker](https://www.docker.com/) installed
- An SSH public key (e.g., `~/.ssh/id_ed25519.pub`)

### Building the Image Locally

To build the container image and embed your SSH public key for root login:

```bash
podman build \
  --build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_ed25519.pub)" \
  -t fedora-bootc-gabriel .
```

Or using Docker:

```bash
docker build \
  --build-arg SSH_PUB_KEY="$(cat ~/.ssh/id_ed25519.pub)" \
  -t fedora-bootc-gabriel .
```

### Building Disk Images with `bootc-image-builder`

To convert the bootable container image into a deployable disk image (e.g., QCOW2 for QEMU/KVM, ISO, or AMI):

```bash
podman run \
  --rm \
  --privileged \
  --security-opt label=type:unconfined_t \
  -v /var/lib/containers/storage:/var/lib/containers/storage \
  -v ./output:/output \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type qcow2 \
  --local fedora-bootc-gabriel
```

The resulting image will be located in `./output/qcow2/disk.qcow2`.

## CI/CD Pipeline

This repository includes a GitHub Actions workflow (`.github/workflows/build-bootc.yml`) that automatically builds and publishes the container image to GitHub Container Registry (`ghcr.io`) on pushes to `main` or via manual dispatch.

### Configuration

Ensure the following repository secret is set in GitHub (**Settings > Secrets and variables > Actions**):

- `SSH_PUB_KEY`: The SSH public key to authorize for root access on booted instances.

## License

This project is open source and available under standard open source licensing terms.
