#!/usr/bin/bash
set -eoux pipefail

# Uma lista por categoria em packages/*.list. Adicionar um pacote = uma linha;
# adicionar uma categoria = um arquivo novo, o glob abaixo pega automaticamente.
# Formato: um pacote por linha, '#' comenta, linhas vazias ignoradas.
mapfile -t packages < <(grep -hvE '^\s*(#|$)' /ctx/packages/*.list)

# --enable-repo=terra: o repo existe na base mas vem desabilitado, e so
# precisamos dele durante esta transacao (fontes nerd, topgrade, starship).
dnf5 -y --enable-repo=terra install "${packages[@]}"
