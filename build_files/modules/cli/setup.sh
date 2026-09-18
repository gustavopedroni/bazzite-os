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
