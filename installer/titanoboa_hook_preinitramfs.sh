#!/usr/bin/env bash
#
set -exo pipefail

# Swap kernel with vanilla and rebuild initramfs.
#
# This is done because we want the initramfs to use a signed
# kernel for secureboot.
kernel_pkgs=(
    kernel
    kernel-core
    kernel-devel
    kernel-devel-matched
    kernel-modules
    kernel-modules-core
    kernel-modules-extra
)
dnf -y versionlock delete "${kernel_pkgs[@]}"
dnf --setopt=protect_running_kernel=False -y remove "${kernel_pkgs[@]}"
(cd /usr/lib/modules && rm -rf -- ./*)
dnf -y --repo fedora,updates --setopt=tsflags=noscripts install kernel kernel-core
kernel=$(find /usr/lib/modules -maxdepth 1 -type d -printf '%P\n' | grep .)
depmod "$kernel"

# bazzite-os: o upstream descobre a imagem com `podman images 'bazzite*'`. A
# nossa e ghcr.io/gustavopedroni/bazzite-os, que esse glob nao casa de forma
# confiavel; um imageref vazio viraria `ostreecontainer --url=:` e a ISO sairia
# quebrada sem falhar o build. INSTALL_IMAGE_PAYLOAD ja vem do Containerfile.
imageref="${INSTALL_IMAGE_PAYLOAD:?}"
imageref="${imageref##*://}"
case "$imageref" in
    *:*) imagetag="${imageref##*:}"; imageref="${imageref%:*}" ;;
    *)   imagetag="latest" ;;
esac

# Include nvidia-gpu-firmware package.
dnf install -yq nvidia-gpu-firmware || :
dnf clean all -yq
