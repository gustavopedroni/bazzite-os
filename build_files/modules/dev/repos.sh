#!/usr/bin/bash
set -eoux pipefail
# android-studio vem do Terra. O cli/ tambem liga, mas o modulo nao depende dele.
dnf5 -y config-manager setopt terra.enabled=1
