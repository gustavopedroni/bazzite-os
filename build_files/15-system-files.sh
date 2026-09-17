#!/usr/bin/bash
set -eoux pipefail

# Depois dos pacotes, de proposito: se o skel da imagem chegar antes, o rpm do
# zsh encontra /etc/skel/.zshrc ja ocupado e larga um .zshrc.rpmnew que vai
# parar no home de todo usuario novo. Copiando depois, os nossos arquivos
# simplesmente ganham.
cp -avf /ctx/system_files/. /
