#!/usr/bin/bash
set -eoux pipefail

# docker.socket em vez de docker.service: o daemon so sobe quando alguem fala
# com /var/run/docker.sock. Containers com restart policy voltam no primeiro
# comando docker, nao no boot. Para subir no boot: systemctl enable docker.service
systemctl enable docker.socket

# O grupo docker nao chega sozinho ao sistema instalado (ver
# files/usr/lib/sysusers.d/docker.conf); este servico poe os usuarios nele.
systemctl enable bazzite-os-add-group@docker.service

# Podman: nada a fazer. O podman.socket de usuario ja vem habilitado pela base.
