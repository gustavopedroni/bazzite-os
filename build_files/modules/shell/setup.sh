#!/usr/bin/bash
set -eoux pipefail

# O Fedora nao tem /etc/zshrc.d: o /etc/zshrc so carrega /etc/profile.d/*.sh,
# que roda sob `emulate -L ksh` e nao serve para codigo zsh. Instalamos o
# loader aqui. Roda sobre a imagem base limpa a cada build, entao e
# deterministico e dispensa guarda de idempotencia.
tee -a /etc/zshrc >/dev/null <<'LOADER'

# Carrega os drop-ins da imagem (bazzite-os).
for _f in /etc/zshrc.d/*.zsh(N); do source "$_f"; done
unset _f
LOADER

# zinit e oh-my-zsh nao existem como RPM. Clone raso e sem .git:
# a versao fica travada pela imagem, o update vem pelo rebuild — nao por um
# `git pull` em runtime num /usr read-only.
clone_pinned() {
    local url="$1" dest="$2"
    git clone --depth 1 "$url" "$dest"
    rm -rf "${dest}/.git"
}

clone_pinned https://github.com/zdharma-continuum/zinit /usr/share/zinit
clone_pinned https://github.com/ohmyzsh/ohmyzsh        /usr/share/oh-my-zsh

# powerlevel10k nao e instalado: a imagem so entrega o perfil pronto em
# /etc/skel/.p10k.zsh. O tema em si voce carrega no seu ~/.zshrc via
#   zinit ice depth"1"; zinit light romkatv/powerlevel10k

# oh-my-zsh grava cache, .zcompdump e $ZSH_CUSTOM dentro de $ZSH por padrao, e
# /usr e read-only no bootc. Os drop-ins 00-env.zsh e 10-omz.zsh redirecionam
# esses tres para o home.

# zsh como shell padrao de usuario novo.
sed -i 's|^SHELL=.*|SHELL=/usr/bin/zsh|' /etc/default/useradd

# Usuario que ja existia (rebase) nao passa pelo useradd: este servico troca o
# shell dele uma vez no boot.
systemctl enable bazzite-os-default-shell.service
