#!/usr/bin/bash
set -eoux pipefail
# Perfil e default no nivel do sistema (/usr/share/konsole + /etc/xdg), nao no
# /etc/skel: o skel so e copiado para usuario novo, e no rebase o usuario ja
# existe. Se o ~/.config/konsolerc do usuario tiver DefaultProfile, o dele vence.
# kwriteconfig6 edita so a chave, mantendo o que a base tiver nesse arquivo.
kwriteconfig6 --file /etc/xdg/konsolerc --group "Desktop Entry" --key DefaultProfile "Profile 1.profile"
