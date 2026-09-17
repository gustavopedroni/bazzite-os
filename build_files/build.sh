#!/usr/bin/bash
set -eoux pipefail

# Orquestrador. Cada etapa vive no seu proprio script, em ordem numerica:
#
#   00-repos.sh         repos de terceiros (vscode, copr)
#   10-packages.sh      dnf5 install lendo packages/*.list
#   15-system-files.sh  copia system_files/ para /
#   20-shell.sh         zsh padrao + zinit + oh-my-zsh + powerlevel10k
#   30-services.sh      presets do systemd
#
# Para adicionar um pacote, edite packages/<categoria>.list — nao este arquivo.

for stage in /ctx/[0-9][0-9]-*.sh; do
    echo "::group:: ===$(basename "$stage")==="
    bash "$stage"
    echo "::endgroup::"
done
