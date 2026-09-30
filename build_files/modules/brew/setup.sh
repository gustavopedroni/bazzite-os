#!/usr/bin/bash
set -eoux pipefail
# Guarda: o brew vem da base (ublue-os/brew). Sem ele, a unit nunca roda.
test -f /usr/share/homebrew.tar.zst
systemctl enable bazzite-os-brew-bundle.service
