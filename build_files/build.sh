#!/usr/bin/bash
set -eoux pipefail

# Cada pasta em modules/ e uma categoria e guarda tudo dela. Todos os arquivos
# sao opcionais:
#   repos.sh       liga os repos de que o modulo precisa
#   packages.list  um pacote por linha ('#' comenta, linhas vazias ignoradas)
#   files/         espelho da raiz, copiado para /
#   setup.sh       o resto: clones, units habilitadas, ajustes de config
#
# As fases rodam para todos os modulos juntos, nesta ordem:
#   repos -> uma unica transacao dnf -> files -> setup
# Adicionar uma categoria = criar uma pasta. Nada aqui precisa mudar.
MODULES=/ctx/modules

enabled_repos() { dnf5 -q repo list --enabled --json | jq -r '.[].id' | sort; }

# 1. Repos. Os que os modulos ligarem sao desligados de novo no fim da fase 2:
#    a imagem final so tem os repos que a base ja tinha ligados, e um repo de
#    terceiro fora do ar nao quebra `rpm-ostree install` de outros pacotes.
repos_before=$(enabled_repos)
for script in "$MODULES"/*/repos.sh; do
    bash "$script"
done

# 2. Pacotes, numa transacao so.
mapfile -t packages < <(grep -hvE '^\s*(#|$)' "$MODULES"/*/packages.list)
dnf5 -y install "${packages[@]}"
comm -13 <(echo "$repos_before") <(enabled_repos) |
    xargs -r -I{} dnf5 -y config-manager setopt '{}.enabled=0'

# 2b. Chaves GPG do Terra por URL em vez de file://. O `config-manager setopt`
#     do dnf5 grava em /etc/dnf/repos.override.d/, mas o depsolve do
#     bootc-image-builder le so /etc/yum.repos.d/ (osbuild chama
#     create_repos_from_dir com config_file_path=/dev/null): para ele os repos
#     do Terra seguem enabled=1 e, com repo_gpgcheck=1, ele busca a chave em
#     file:///etc/pki/rpm-gpg/... — caminho que o bib nao reescreve para a raiz
#     da imagem montada, e a ISO morre no depsolve (bootc-image-builder#1188).
#     A URL serve a mesma chave que o terra-gpg-keys instala, entao nada de
#     verificacao e afrouxado.
sed -i -E 's|^gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-terra(\$releasever[a-z-]*)$|gpgkey=https://repos.fyralabs.com/terra\1/key.asc|' /etc/yum.repos.d/terra*.repo

# 3. Arquivos. Depois dos pacotes de proposito: se o skel chegar antes, o rpm do
#    zsh encontra /etc/skel/.zshrc ocupado e larga um .zshrc.rpmnew no home de
#    todo usuario novo. Copiando depois, os nossos arquivos ganham.
for dir in "$MODULES"/*/files; do
    cp -avf "$dir"/. /
done

# 4. Setup. Roda depois dos arquivos: um modulo pode habilitar uma unit que
#    outro modulo entrega (ex.: bazzite-os-add-group@, de user-groups/).
for script in "$MODULES"/*/setup.sh; do
    bash "$script"
done
