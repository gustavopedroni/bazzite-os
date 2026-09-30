#!/usr/bin/bash
set -eoux pipefail
# --global: vale para todos os usuarios. Nao usar `preset-all --global` (ver
# nvibrant/setup.sh).
systemctl --global enable bazzite-os-ngrok-box.service
