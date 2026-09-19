#!/usr/bin/bash
set -eoux pipefail
# A lista fica em files/usr/share/flatpak/preinstall.d/bazzite-os.preinstall.
systemctl enable bazzite-os-flatpak-preinstall.service
