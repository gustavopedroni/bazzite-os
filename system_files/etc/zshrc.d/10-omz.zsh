# oh-my-zsh, instalado em /usr/share pela imagem.

export ZSH=/usr/share/oh-my-zsh

# O clone da imagem nao tem .git (versao travada pela imagem, atualiza no
# rebuild). Sem isso o omz tenta um `git pull` num /usr read-only a cada login.
export DISABLE_AUTO_UPDATE=true
zstyle ':omz:update' mode disabled

# Sem tema do omz: o prompt vem do powerlevel10k, carregado no ~/.zshrc via
# zinit. Deixar um tema aqui so faria o omz desenhar um prompt que o p10k
# substitui um instante depois.
ZSH_THEME=""

# $ZSH_CUSTOM aponta para $ZSH/custom por padrao, que aqui e /usr — read-only.
# Redireciona para o home: e dali que o omz carrega seus *.zsh de aliases,
# plugins e temas proprios.
export ZSH_CUSTOM="${XDG_DATA_HOME:-$HOME/.local/share}/oh-my-zsh-custom"
mkdir -p "$ZSH_CUSTOM"/{plugins,themes}

plugins=(git)

source "$ZSH/oh-my-zsh.sh"

# zinit disponivel para o que voce quiser adicionar no ~/.zshrc:
#   source "$ZINIT_HOME/zinit.zsh"
#   zinit light algum/plugin
export ZINIT_HOME=/usr/share/zinit
