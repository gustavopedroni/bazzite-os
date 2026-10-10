#!/usr/bin/bash
set -eoux pipefail
# coolercontrol e lact vem do Terra. O dev/ tambem liga, mas o modulo nao depende dele.
dnf5 -y config-manager setopt terra.enabled=1
