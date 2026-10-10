#!/usr/bin/bash
set -eoux pipefail
systemctl enable coolercontrold.service lactd.service
