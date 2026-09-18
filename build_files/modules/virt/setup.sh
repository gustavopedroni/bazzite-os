#!/usr/bin/bash
set -eoux pipefail
# Usuario no grupo libvirt: o virt-manager acessa qemu:///system sem pedir senha.
systemctl enable bazzite-os-add-group@libvirt.service
