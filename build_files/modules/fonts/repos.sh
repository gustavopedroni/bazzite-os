#!/usr/bin/bash
set -eoux pipefail
# As Nerd Fonts vem do Terra. A base traz terra.repo (desligado) e a chave GPG.
dnf5 -y config-manager setopt terra.enabled=1
