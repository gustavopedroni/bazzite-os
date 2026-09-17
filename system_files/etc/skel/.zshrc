# Só as suas variáveis e os plugins que você escolhe.
#
# A imagem entrega, via /etc/zshrc.d/: oh-my-zsh, histórico, completions e o
# zinit pronto em $ZINIT_HOME. Os plugins são todos seus, carregados abaixo.
# O perfil do powerlevel10k já está em ~/.p10k.zsh.

# Instant prompt do powerlevel10k. Tem que ficar no topo: qualquer coisa que
# escreva no terminal antes disto quebra o instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# --- Plugins via zinit ---
# $ZINIT_HOME vem da imagem, o zinit já está instalado em /usr/share/zinit —
# sem o bloco de auto-instalação que o installer do zinit costuma colar aqui.
source "$ZINIT_HOME/zinit.zsh"
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

zinit load zdharma-continuum/history-search-multi-word
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting

### End of Zinit's installer chunk
zinit ice depth"1" # git clone depth
zinit light romkatv/powerlevel10k
# Os annexes do zinit (as-monitor, bin-gem-node, patch-dl, rust) ficam de fora:
# são 4 clones a mais no primeiro login e nenhum ice usado aqui precisa deles.
# Se algum plugin novo reclamar de ice desconhecido, é aqui que eles entram.

# Tema. Rode `p10k configure` para mudar.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# SSH: o /etc/profile.d/keychain.sh do Fedora já sobe o agente e carrega
# tudo que for chave privada em ~/.ssh/. Não precisa de nada aqui.

# Docker e Podman convivem. Por padrão a CLI do docker fala com o dockerd.
# Para apontá-la ao podman (rootless) nesta sessão, descomente:
# export DOCKER_HOST="unix:///run/user/$(id -u)/podman/podman.sock"

# --- Ambiente pessoal ---

export ELECTRON_OZONE_PLATFORM_HINT=auto

export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
path=(
  "$ANDROID_SDK_ROOT"/{emulator,platform-tools,cmdline-tools/latest/bin}
  "$HOME/.maestro/bin"
  $path
)

# asdf: instale em ~/.local/bin (já está no PATH pelo .zprofile).
if [[ -d "${ASDF_DATA_DIR:-$HOME/.asdf}" ]]; then
  path=("${ASDF_DATA_DIR:-$HOME/.asdf}/shims" $path)
  fpath=("${ASDF_DATA_DIR:-$HOME/.asdf}/completions" $fpath)
fi

alias flatpak-kill-all="flatpak ps --columns=instance | xargs -r -n 1 flatpak kill"

# Tokens e chaves ficam fora do git. chmod 600.
[[ -f ~/.config/secrets.env ]] && source ~/.config/secrets.env
