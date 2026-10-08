#!/usr/bin/bash
set -eoux pipefail
# Defaults no nivel do sistema (/etc/xdg), como no terminal/: valem para todo
# usuario, inclusive o que ja existia no rebase. O ~/.config do usuario vence.

# Layout us-intl: ' + e = é.
kwriteconfig6 --file /etc/xdg/kxkbrc --group Layout --key Use true
kwriteconfig6 --file /etc/xdg/kxkbrc --group Layout --key LayoutList us
kwriteconfig6 --file /etc/xdg/kxkbrc --group Layout --key VariantList intl

# fcitx5 como metodo de entrada do KWin. Sem isso o KWin 6.7 usa o
# plasma-keyboard, que perde o acento quando se digita rapido; e sem metodo de
# entrada nenhum o Chrome (flatpak) nao gera o ç. O fcitx5 compoe as teclas
# mortas para todos os apps lendo o ~/.XCompose. O grupo de entrada dele vem
# de /etc/xdg/fcitx5/profile. O ~/.XCompose (´ + c = ç) vai pelo /etc/skel,
# entao so usuario novo ganha: o unico caminho de sistema seria XCOMPOSEFILE,
# que impediria cada usuario de ter o proprio ~/.XCompose.
# Sem GTK_IM_MODULE/QT_IM_MODULE: no Plasma Wayland os apps falam com o fcitx5
# pelo protocolo text-input, e essas variaveis atrapalham.
# Via launcher (experimental no fcitx5 5.1): o KWin sobe so o launcher, que
# repassa a conexao de input method pelo D-Bus a um fcitx5 independente. Assim
# o fcitx5 pode ser reiniciado (addons, mozc) sem perder o papel de IM. Se der
# problema, o modo estavel e org.fcitx.Fcitx5.desktop no lugar.
kwriteconfig6 --file /etc/xdg/kwinrc --group Wayland --key InputMethod /usr/share/applications/fcitx5-wayland-launcher.desktop
