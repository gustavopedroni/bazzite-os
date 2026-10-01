#!/usr/bin/bash
set -eoux pipefail

# neovim no lugar do vim. A base traz o vim-enhanced, dono de /usr/bin/vim, e o
# alternatives nao sobrescreve arquivo de pacote: ele sai. So plugins de vim e o
# vim-default-editor dependem dele. O `vi` continua sendo o vim-minimal.
dnf5 -y remove vim-enhanced
alternatives --install /usr/bin/vim vim /usr/bin/nvim 100

# Editor do git para todos. core.editor vence o EDITOR (nano no Fedora); um
# core.editor no ~/.gitconfig ainda vence este.
git config --system core.editor nvim
# `git init` cria main em vez de master (e sem o aviso de hint).
git config --system init.defaultBranch main
# `git pull` faz rebase em vez de commit de merge.
git config --system pull.rebase true
# Guarda as mudancas nao commitadas antes do rebase e devolve depois, em vez de
# recusar o pull com a arvore suja.
git config --system rebase.autoStash true

# Servico do hardinfo2. Sem `--now` no build: nao ha systemd rodando, ele sobe
# no boot.
systemctl enable hardinfo2.service
