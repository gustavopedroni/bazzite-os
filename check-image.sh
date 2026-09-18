#!/usr/bin/bash
# Confere, no PC que roda a imagem, se o que build_files/modules/ entrega chegou.
# Rode de dentro de um clone do repo:
#   git clone --depth 1 https://github.com/gustavopedroni/bazzite-os
#   cd bazzite-os && ./check-image.sh
#
# Pacotes e arquivos saem dos proprios modulos (packages.list e files/), como no
# build.sh: modulo novo e conferido sem mexer aqui. O resto confere o que os
# setup.sh fazem. Sai com 1 se houver alguma falha.
set -uo pipefail
cd "$(dirname "$0")" || exit 1
MODULES=build_files/modules
fails=0 warns=0

ok()   { echo "  ✓ $*"; }
bad()  { echo "  ✗ $*"; fails=$((fails + 1)); }
warn() { echo "  ! $*"; warns=$((warns + 1)); }
# check "descricao" comando...: ✓ se o comando passar, ✗ se nao.
check() { local msg="$1"; shift; if "$@" &>/dev/null; then ok "$msg"; else bad "$msg"; fi; }

echo "== Imagem"
# shellcheck source=image-template.env
source image-template.env
image="ghcr.io/${REPO_ORGANIZATION,,}/${IMAGE_NAME}"
status=$(rpm-ostree status --json 2>/dev/null)
booted=$(jq -c '.deployments[] | select(.booted)' <<<"$status" 2>/dev/null)
ref=$(jq -r '."container-image-reference" // empty' <<<"$booted" 2>/dev/null)
if [[ "$ref" == *"$image"* ]]; then
    ok "bootado em $ref (versao $(jq -r '.version // "?"' <<<"$booted"))"
    digest=$(jq -r '."container-image-reference-digest" // empty' <<<"$booted")
    latest=$(skopeo inspect --format '{{.Digest}}' "docker://$image:$DEFAULT_TAG" 2>/dev/null)
    if [[ -z "$digest" || -z "$latest" ]]; then
        warn "nao deu para comparar com a imagem mais nova do ghcr"
    elif [[ "$digest" == "$latest" ]]; then
        ok "e a imagem mais nova do ghcr"
    else
        warn "tem imagem mais nova no ghcr: sudo bootc upgrade e reinicie"
    fi
else
    bad "bootado em '${ref:-?}', esperado $image (sudo bootc switch $image:$DEFAULT_TAG)"
fi
jq -e '.deployments[] | select(.staged)' <<<"$status" &>/dev/null &&
    warn "update ja baixado, falta reiniciar"

echo "== Pacotes (*/packages.list)"
# Mesmo filtro do build.sh. Grupos (@...) ficam de fora: nao sao um pacote so.
mapfile -t pkgs < <(grep -hvE '^\s*(#|$|@)' "$MODULES"/*/packages.list | sort -u)
missing=0
for p in "${pkgs[@]}"; do
    rpm -q --whatprovides "$p" &>/dev/null || { bad "$p nao instalado"; missing=$((missing + 1)); }
done
((missing == 0)) && ok "todos os ${#pkgs[@]} instalados"

echo "== Arquivos (*/files/)"
nfiles=0
for dir in "$MODULES"/*/files; do
    while IFS= read -r -d '' src; do
        nfiles=$((nfiles + 1))
        dst="/${src#"$dir"/}"
        if [[ ! -e "$dst" ]]; then
            bad "$dst nao existe"
        elif [[ -r "$dst" ]] && ! cmp -s "$src" "$dst"; then
            warn "$dst difere do repo (editado no PC ou imagem antiga)"
        fi
    done < <(find "$dir" -type f -print0)
done
ok "$nfiles arquivos conferidos"

echo "== shell"
check "loader do /etc/zshrc.d no /etc/zshrc" grep -q 'zshrc.d' /etc/zshrc
check "zinit em /usr/share/zinit" test -f /usr/share/zinit/zinit.zsh
check "oh-my-zsh em /usr/share/oh-my-zsh" test -f /usr/share/oh-my-zsh/oh-my-zsh.sh
check "SHELL=/usr/bin/zsh no /etc/default/useradd" grep -qx 'SHELL=/usr/bin/zsh' /etc/default/useradd
check "bazzite-os-default-shell.service habilitado" systemctl is-enabled bazzite-os-default-shell.service
check "bazzite-os-default-shell.service ja rodou" test -e /var/lib/bazzite-os/default-shell
check "seu shell de login e o zsh" test "$(getent passwd "$USER" | cut -d: -f7)" = /usr/bin/zsh
if [[ ! -f "$HOME/.zshrc" ]]; then
    bad "$HOME/.zshrc nao existe"
elif cmp -s "$HOME/.zshrc" /etc/skel/.zshrc; then
    ok "$HOME/.zshrc e o da imagem"
else
    warn "$HOME/.zshrc difere do /etc/skel/.zshrc (editado por voce, ou nao foi trocado)"
fi
check "$HOME/.p10k.zsh existe" test -f "$HOME/.p10k.zsh"
if [[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/zinit/plugins/romkatv---powerlevel10k" ]]; then
    ok "plugins do zinit baixados"
else
    warn "plugins do zinit ainda nao baixados: abra um zsh com internet"
fi

echo "== containers"
check "docker.socket habilitado" systemctl is-enabled docker.socket
check "bazzite-os-add-group@docker.service habilitado" systemctl is-enabled bazzite-os-add-group@docker.service
check "$USER no grupo docker" grep -qw docker <(id -nG "$USER")

echo "== fonts"
check "fonte MesloLGS Nerd Font" grep -q 'MesloLGS Nerd Font' <(fc-list : family)

echo "== nvibrant (servico de usuario: systemctl --user status nvibrant)"
check "uvx instalado" command -v uvx
check "habilitado para todos os usuarios" test -L /etc/systemd/user/default.target.wants/nvibrant.service
check "habilitado para voce" systemctl --user is-enabled nvibrant.service
user_unit="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/nvibrant.service"
[[ -f "$user_unit" ]] && warn "$user_unit sobrepoe o da imagem"
# Sem RemainAfterExit (ex.: uma copia antiga no home) a unit fica inactive
# depois de rodar; Result=success com saida registrada tambem vale.
nv() { systemctl --user show -p "$1" --value nvibrant.service; }
if [[ ! -e /proc/driver/nvidia/version ]]; then
    warn "driver NVIDIA nao carregado: a unit e pulada (ConditionPathExists)"
elif systemctl --user is-active -q nvibrant.service ||
     [[ $(nv Result) == success && $(nv ExecMainExitTimestampMonotonic) != 0 ]]; then
    ok "rodou com sucesso neste login"
else
    bad "nao esta ativo. Ultimas linhas do log:"
    journalctl --user -u nvibrant.service -b -n 5 --no-pager 2>&1 | sed 's/^/      /'
fi

echo "== terminal"
check "DefaultProfile no /etc/xdg/konsolerc" grep -qx 'DefaultProfile=Profile 1.profile' /etc/xdg/konsolerc
user_profile=$(grep -s '^DefaultProfile=' "${XDG_CONFIG_HOME:-$HOME/.config}/konsolerc" | cut -d= -f2-)
if [[ -n "$user_profile" && "$user_profile" != "Profile 1.profile" ]]; then
    warn "seu konsolerc usa DefaultProfile=$user_profile, e ele vence o da imagem"
fi

# Por ultimo porque pede a senha.
echo "== sudo (vai pedir a senha: se aparecerem asteriscos, o pwfeedback funciona)"
sudo -k
check "pwfeedback ativo no sudo" grep -q pwfeedback <(sudo -l 2>/dev/null)

echo
echo "$fails falha(s), $warns aviso(s)"
((fails == 0))
