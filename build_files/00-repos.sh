#!/usr/bin/bash
set -eoux pipefail

# O Bazzite ja traz terra.repo (com enabled=0) e a chave GPG do Terra em
# /etc/pki/rpm-gpg/. Nao instalamos terra-release: 10-packages.sh habilita o
# repo so durante a transacao com --enable-repo, e a imagem final continua com
# o Terra desabilitado, igual o Bazzite entrega.

# VS Code: repo da Microsoft, nao existe na base.
rpm --import https://packages.microsoft.com/keys/microsoft.asc
tee /etc/yum.repos.d/vscode.repo >/dev/null <<'REPO'
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
autorefresh=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
REPO

# Docker: repo oficial. So a CLI e os plugins sao instalados (ver
# packages/containers.list) — o daemon fica por conta do podman.
dnf5 -y config-manager addrepo --from-repofile=https://download.docker.com/linux/fedora/docker-ce.repo

# Sem COPRs. O nvibrant costumava vir do copr starfish/nvibrant, mas aquele
# binario falha no driver atual (AllocDevice ioctl failed) — quem funciona e o
# `uvx nvibrant`, que resolve o binario certo para a versao do driver em uso.
