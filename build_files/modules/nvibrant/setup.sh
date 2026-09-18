#!/usr/bin/bash
set -eoux pipefail
# --global cria o link em /etc/systemd/user: vale para todos os usuarios.
# Nao usar `systemctl preset-all --global`: ele reaplica os presets a TODAS as
# units de usuario, e o 99-default-disable.preset do Bazzite desligaria as dele
# (bazzite-user-setup, bazzite-dynamic-fixes, ...).
systemctl --global enable nvibrant.service
