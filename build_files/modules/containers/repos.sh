#!/usr/bin/bash
set -eoux pipefail
# Docker: repo oficial (daemon + CLI + plugins).
dnf5 -y config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo
