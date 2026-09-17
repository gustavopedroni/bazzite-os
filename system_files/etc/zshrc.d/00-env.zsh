# Historico e opcoes base. Vem da imagem: nao precisa estar no ~/.zshrc.

HISTFILE="${HISTFILE:-$HOME/.zsh_history}"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY       # grava timestamp
setopt INC_APPEND_HISTORY     # grava na hora, nao so ao sair
setopt SHARE_HISTORY          # compartilha entre shells abertos
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE      # comando com espaco na frente nao entra no historico
setopt HIST_REDUCE_BLANKS

# Cache dos plugins. /usr e read-only no bootc, entao tudo que e escrito em
# runtime tem que sair de la.
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
export ZSH_COMPDUMP="$ZSH_CACHE_DIR/zcompdump-${ZSH_VERSION}"
mkdir -p "$ZSH_CACHE_DIR/completions"
