#!/usr/bin/bash
set -eoux pipefail

# docker.socket em vez de docker.service: ativacao por socket, o daemon so sobe
# quando alguem fala com /var/run/docker.sock. Sem custo com a maquina parada.
systemctl enable docker.socket

# O preset de usuario em system_files/usr/lib/systemd/user-preset/ habilita o
# podman.socket no primeiro login. Unit de usuario nao pode ser habilitada em
# tempo de imagem (nao existe /run/user/<uid> no build), por isso preset.
systemctl preset-all --global || true
